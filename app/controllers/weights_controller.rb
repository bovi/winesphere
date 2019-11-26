class WeightsController < ApplicationController
  protect_from_forgery :except => [:new_entry]
  before_action :set_weight, only: [:show, :edit, :update, :destroy]

  # GET /weights
  # GET /weights.json
  def index
    @weights = Weight.all
  end

  # GET /weights/1
  # GET /weights/1.json
  def show
  end

  # GET /weights/new
  def new
    @weight = Weight.new
  end

  # GET /weights/1/edit
  def edit
  end

  def new_entry
    scale_data = JSON.parse(params[:data])
    scale = Scale.find_by(name: scale_data['scale'])
    weight = Weight.new
    weight.scale = scale
    weight.raw = scale_data['weight'].abs
    weight.weight = ((scale_data['weight'].abs - scale.offset) * scale.calibration).abs
    weight.battery = scale_data['battery']
    weight.uptime = scale_data['uptime']
    if weight.save
      render inline: '{"status": "ok"}', status: 200
    else
      render inline: '{"status": "ko"}', status: 500
    end
  end

  # POST /weights
  # POST /weights.json
  def create
    @weight = Weight.new(weight_params)

    respond_to do |format|
      if @weight.save
        format.html { redirect_to @weight, notice: 'Weight was successfully created.' }
        format.json { render :show, status: :created, location: @weight }
      else
        format.html { render :new }
        format.json { render json: @weight.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /weights/1
  # PATCH/PUT /weights/1.json
  def update
    respond_to do |format|
      if @weight.update(weight_params)
        format.html { redirect_to @weight, notice: 'Weight was successfully updated.' }
        format.json { render :show, status: :ok, location: @weight }
      else
        format.html { render :edit }
        format.json { render json: @weight.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /weights/1
  # DELETE /weights/1.json
  def destroy
    @weight.destroy
    respond_to do |format|
      format.html { redirect_to weights_url, notice: 'Weight was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_weight
      @weight = Weight.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def weight_params
      params.require(:weight).permit(:weight, :scale_id, :raw, :battery, :uptime)
    end
end
