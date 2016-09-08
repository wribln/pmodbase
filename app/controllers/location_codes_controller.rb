class LocationCodesController < ApplicationController
  require 'csv'
  include ControllerMethods
  initialize_feature FEATURE_ID_LOCATION_CODES, FEATURE_ACCESS_VIEW
  before_action :set_location_code, only: [ :show, :edit, :update, :destroy ]

  # GET /scls

  def index
    @filter_fields = filter_params
    respond_to do |format|
      format.html do
        @location_codes = LocationCode.filter( @filter_fields ).paginate( page: params[ :page ])
      end
      format.xls do # no pagination for CSV format
        @location_codes = LocationCode.filter( @filter_fields )
        set_header( :xls, 'location_codes.csv' )
      end
    end
  end

  # GET /scls/1

  def show
  end

  # GET /scls/new

  def new
    @location_code = LocationCode.new
  end

  # GET /scls/1/edit

  def edit
  end

  # POST /scls

  def create
    @location_code = LocationCode.new( location_code_params )
    respond_to do |format|
      if @location_code.save
        format.html { redirect_to @location_code, notice: t( 'location_codes.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /scls/1

  def update
    respond_to do |format|
      if @location_code.update(location_code_params)
        format.html { redirect_to @location_code, notice: t( 'location_codes.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /scls/1

  def destroy
    @location_code.destroy
    respond_to do |format|
      format.html { redirect_to location_codes_url, notice: t( 'location_codes.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_location_code
      @location_code = LocationCode.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def location_code_params
      params.require( :location_code ).permit( :code, :label, :loc_type, :center_point, :start_point, :end_point, :length, :note )
    end

    def filter_params
      params.slice( :as_code, :as_desc, :as_note, :ff_type ).clean_up
    end

end
