class ScalesController < ApplicationController
  before_action :set_scale, only: [:show, :edit, :update, :destroy]

  # GET /scales
  # GET /scales.json
  def index
    @scales = Scale.all
  end

  # GET /scales/1
  # GET /scales/1.json
  def show
    h = @scale.weights
              .where('updated_at > ?', 1.hours.ago)
              .group_by_minute(:created_at)
              .average(:weight)
    h = h.each do |k,v|
      h[k] = v / 1000.0 if v
    end
    render json: h
  end

  def show_admin
    @scale = Scale.find(params['scale_id'])
    h = @scale.weights
              .where('updated_at > ?', 6.hours.ago)
              .group_by_minute(:created_at)
              .count
    render json: h
  end

  # GET /scales/new
  def new
    @scale = Scale.new
    @booths = Booth.all
  end

  # GET /scales/1/edit
  def edit
  end

  # POST /scales
  # POST /scales.json
  def create
    @scale = Scale.new(scale_params)

    respond_to do |format|
      if @scale.save
        format.html { redirect_to @scale, notice: 'Scale was successfully created.' }
        format.json { render :show, status: :created, location: @scale }
      else
        format.html { render :new }
        format.json { render json: @scale.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scales/1
  # PATCH/PUT /scales/1.json
  def update
    respond_to do |format|
      if @scale.update(scale_params)
        format.html { redirect_to @scale, notice: 'Scale was successfully updated.' }
        format.json { render :show, status: :ok, location: @scale }
      else
        format.html { render :edit }
        format.json { render json: @scale.errors, status: :unprocessable_entity }
      end
    end
  end
  def offset
    @scale = Scale.find(params[:scale_id])
    current_offset = @scale.weights.last.raw.abs
    if current_offset
      @scale.offset = current_offset
      if @scale.save
        redirect_to scales_url, notice: 'Offset was successfully set'
      else
        redirect_to scales_url, notice: 'Could not update the offset of this Scale'
      end
    else
      redirect_to scales_url, notice: 'No weight to set an offset for this Scale'
    end
  end
  def rescale_all_values
    @scale = Scale.find(params[:scale_id])
    @scale.weights.each do |w|
      w.weight = ((w.raw - @scale.offset) / @scale.calibration).abs
      w.save!
    end
    render html: 'ok'
  end

  # DELETE /scales/1
  # DELETE /scales/1.json
  def destroy
    @scale.destroy
    respond_to do |format|
      format.html { redirect_to scales_url, notice: 'Scale was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scale
      @scale = Scale.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scale_params
      params.require(:scale).permit(:name, :booth_id, :offset, :calibration)
    end
end
