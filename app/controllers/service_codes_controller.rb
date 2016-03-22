class ServiceCodesController < ApplicationController
  require 'csv'
  include ControllerMethods
  initialize_feature FEATURE_ID_SERVICE_CODES, FEATURE_ACCESS_VIEW
  before_action :set_service_code, only: [ :show, :edit, :update, :destroy ]

  # GET /fncs

  def index
    @filter_fields = filter_params
    respond_to do |format|
      format.html do
        @service_codes = ServiceCode.filter( filter_params ).paginate( page: params[ :page ])
      end
      format.xls do # no pagination for CSV format
        @service_codes = ServiceCode.filter( filter_params )
        set_header( :xls, 'service_codes.csv' )
      end
    end
  end

  # GET /fncs/1

  def show
  end

  # GET /fncs/new

  def new
    @service_code = ServiceCode.new
  end

  # GET /fncs/1/edit

  def edit
  end

  # POST /fncs

  def create
    @service_code = ServiceCode.new( service_code_params )
    respond_to do |format|
      if @service_code.save
        format.html { redirect_to @service_code, notice: t( 'service_codes.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /fncs/1

  def update
    respond_to do |format|
      if @service_code.update( service_code_params )
        format.html { redirect_to @service_code, notice: t( 'service_codes.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /fncs/1

  def destroy
    @service_code.destroy
    respond_to do |format|
      format.html { redirect_to service_codes_url, notice: t( 'service_codes.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_service_code
      @service_code = ServiceCode.find( params[:id] )
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def service_code_params
      params.require( :service_code ).permit( :code, :label, :active, :master, :standard, :heading, :note )
    end

    def filter_params
      params.slice( :as_code, :as_desc ).clean_up
    end

end
