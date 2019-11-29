class BoothsController < ApplicationController
  before_action :set_booth, only: [:show, :edit, :update, :destroy]

  # GET /booths
  # GET /booths.json
  def index
    @booths = Booth.all
  end

  # GET /booths/1
  # GET /booths/1.json
  def show
  end

  # GET /booths/new
  def new
    @booth = Booth.new
  end

  # GET /booths/1/edit
  def edit
  end

  def kitchen
    @weights = []
    @temps = []
    [1, 2].each do |i|
      b = Booth.find(i)
      @weights[i] = if b.scales.first.weights.last
        (b.scales.first.weights.last.weight / 1000.0).round(1)
      else
        '~'
      end
      @temps[i] = if b.thermometers.first.temperatures.last
        b.thermometers.first.temperatures.last.temp.round(1)
      else
        '~'
      end
    end
  end

  def overview
    @weights = []
    @temps = []
    [1, 2].each do |i|
      b = Booth.find(i)
      @weights[i] = if b.scales.first.weights.last
        (b.scales.first.weights.last.weight / 1000.0).round(1)
      else
        '~'
      end
      @temps[i] = if b.thermometers.first.temperatures.last
        b.thermometers.first.temperatures.last.temp.round(1)
      else
        '~'
      end
    end
  end

  def purge
    Weight.delete_all
    Temperature.delete_all
    render html: 'ok'
  end

  def liter
    @booth = Booth.find(params[:booth_id])
    if @booth.scales.first.weights
      ml = @booth.scales.first.weights
                     .where('created_at > ?', 1.hours.ago)
                     .group_by_minute(:created_at)
                     .average(:weight).values.last
      if ml
        render html: (ml / 1000.0).round(1)
      else
        render html: 0
      end
    else
      render html: 0
    end
  end
  def empty
    @booth = Booth.find(params[:booth_id])
    if @booth.scales.first.weights
      h = @booth.scales.first.weights
                       .where(created_at: (DateTime.now-10.minutes)..DateTime.now)
                       .group_by_minute(:created_at).average(:weight).to_a
      if h.count >= 3
        now = h[-1]
        max = h[-2]
        if max[1]
          # find the last local maximum
          h[0..-3].reverse.each do |i|
            next if i.nil?
            if i[1] >= max[1]
              # still upwards
              max = i
            else
              # refill detected
              break
            end
          end
        end
        if now[1] and max[1]
          if now[1] > max[1]
            # refill just now
            render html: '~'
          else
            consumption = max[1] - now[1]
            consumption_time = (now[0] - max[0]) / 60.0
            if consumption_time > 0
              consumption_per_min = consumption / consumption_time
              if consumption_per_min > 0
                min_until_empty = now[1] / consumption_per_min
                output = ''
                if min_until_empty > 30
                  output = '>30min'
                else
                  output = "#{min_until_empty.round}min"
                end
                render html: output
              else
                render html: '~'
              end
            else
              render html: '~'
            end
          end
        else
          render html: '~'
        end
      else
        render html: '~'
      end
    else
      render html: '~'
    end
  end
  def cups
    ## cLevel = average filllevel of current minute
    ## pLevel = average filllevel of previous minute
    ## is cLevel > pLevel
    ### refill since last minute (no calculation)
    ## is pLevel > cLevel
    ### no refill since last minute (calculate cups per minute)
    ### consumption = pLevel - cLevel

    # Corner Cases:
    ## * will be refilled several-times per minute
    ## * single values might be screwed

    @booth = Booth.find(params[:booth_id])
    if @booth.scales.first.weights
      h = @booth.scales.first.weights
                       .where(created_at: @booth.open_at..DateTime.now)
                       .group_by_minute(:created_at).average(:weight).to_a
      last_data = nil
      last_time = nil
      ml = 0
      new_ml = 0

      # iterate above all except the last one
      h[0..-2].each do |a|
        k = a[0]
        v = a[1]
        next if v.nil?
        if last_data
          if v > last_data
            # refill
          else
            # no refill
            begin
              new_ml = last_data - v
            rescue FloatDomainError
              # fixme
              # an error I don't yet understand
              new_ml = 0
            end


            # per minute not more than 3000ml
            new_ml = 1000 if new_ml > 4000

            ml = ml + new_ml
          end
        end
        last_data = v
        last_time = k
      end

      render html: (ml / 1000.0).round(1)
    else
      render html: '~'
    end
  end
  def temp
    @booth = Booth.find(params[:booth_id])
    if @booth.thermometers.first.temperatures
      temp = @booth.thermometers.first.temperatures
                         .where('created_at > ?', 1.hours.ago)
                         .group_by_minute(:created_at)
                         .average(:temp).values.last
      if temp
        render html: temp.round(1)
      else
        render html: 0
      end
    else
      render html: 0
    end
  end

  # POST /booths
  # POST /booths.json
  def create
    #@booth = Booth.new(booth_params)

    respond_to do |format|
      if true #@booth.save
        format.html { redirect_to @booth, notice: 'Booth was successfully created.' }
        format.json { render :show, status: :created, location: @booth }
      else
        format.html { render :new }
        format.json { render json: @booth.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /booths/1
  # PATCH/PUT /booths/1.json
  def update
    respond_to do |format|
      dt = Time.new(params["open_at"]["year"].to_i, params["open_at"]["month"].to_i,
                    params["open_at"]["day"].to_i, params["open_at"]["hour"].to_i,
                    params["open_at"]["minute"].to_i)
      @booth.open_at = dt
      if @booth.save
        format.html { redirect_to booths_url, notice: 'Booth was successfully updated.' }
        format.json { render :show, status: :ok, location: @booth }
      else
        format.html { render :edit }
        format.json { render json: @booth.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /booths/1
  # DELETE /booths/1.json
  def destroy
    #@booth.destroy
    respond_to do |format|
      format.html { redirect_to booths_url, notice: 'Booth was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booth
      @booth = Booth.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def booth_params
      params.require(:booth).permit(:name, :open_at)
    end
end
