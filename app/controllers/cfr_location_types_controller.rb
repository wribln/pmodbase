class CfrLocationTypesController < ApplicationController

  initialize_feature FEATURE_ID_CFR_LOCATION_TYPES, FEATURE_ACCESS_SOME 
  before_action :set_cfr_location_type, only: [ :show, :edit, :update, :destroy ]

  # GET /cfu

  def index
    @cfr_location_types = CfrLocationType.all
  end

  # GET /cfu

  def show
  end

  # GET /cfu

  def new
    @cfr_location_type = CfrLocationType.new
  end

  # GET /cfu

  def edit
  end

  # POST /cfu

  def create
    @cfr_location_type = CfrLocationType.new( cfr_location_type_params )
    respond_to do |format|
      if @cfr_location_type.save
        format.html { redirect_to @cfr_location_type, notice: I18n.t( 'cfr_location_types.msg.create_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /cfu

  def update
    respond_to do |format|
      if @cfr_location_type.update(cfr_location_type_params)
        format.html { redirect_to @cfr_location_type, notice: I18n.t( 'cfr_location_types.msg.update_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /cfu

  def destroy
    @cfr_location_type.destroy
    respond_to do |format|
      format.html { redirect_to cfr_location_types_url, notice: I18n.t( 'cfr_location_types.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
  
    def set_cfr_location_type
      @cfr_location_type = CfrLocationType.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def cfr_location_type_params
      params.require( :cfr_location_type ).permit(
        :label, :location_type, :path_prefix, :concat_char, :project_dms, :note )
    end
end
