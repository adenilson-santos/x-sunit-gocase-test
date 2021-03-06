class SurvivorsController < ApplicationController
  before_action :set_survivor, only: [:show, :update]

  # GET /survivors
  def index
    @survivors = Survivor.all.order(:name)

    render json: @survivors, include: [:denunciations, :location]
  end

  # GET /survivors/1
  def show
    render json: @survivor, include: [:denunciations, :location]
  end

  # POST /survivors
  def create
    @survivor = Survivor.new(survivor_params)

    if params[:location_attributes].blank?
      Location.create!(
        latitude: Faker::Address.latitude,
        longitude: Faker::Address.latitude,
        survivor: @survivor
      )
    end

    if @survivor.save
      render json: @survivor, status: :created, location: @survivor, include: [:denunciations, :location]
    else
      render json: @survivor.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /survivors/1
  def update
    if !@survivor.abducted
      
      if @survivor.update(survivor_params)
        render json: @survivor, include: [:denunciations, :location]
      else
        render json: @survivor.errors, status: :unprocessable_entity
      end

    else
      render json: return_message(:'survivors.already_abducted')
    end
  end

  # DELETE /survivors/1 this route was deleted.
  # def destroy
  #   @survivor.destroy
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_survivor
      survivor_id = params[:id]

      if params[:location_id]
        survivor_id = Location.find(params[:location_id]).survivor_id
      elsif params[:denunciation_id]
        survivor_id = Denunciation.find(params[:denunciation_id]).survivor_id
      end
      
      @survivor = Survivor.find(survivor_id)
    end

    # Only allow a trusted parameter "white list" through.
    def survivor_params
      params.require(:survivor).permit(
        :name, 
        :age, 
        :gender, 
        location_attributes: [:id, :latitude, :longitude]
      )
    end
end
