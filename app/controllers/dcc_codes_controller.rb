class DccCodesController < ApplicationController
  require 'csv'
  include ControllerMethods
  initialize_feature FEATURE_ID_DCC_CODES, FEATURE_ACCESS_INDEX
  before_action :set_dcc_code, only: [ :show, :edit, :update, :destroy ]

  # GET /fncs

  def index
    @filter_fields = filter_params
    respond_to do |format|
      format.html do
        @dcc_codes = DccCode.filter( filter_params ).paginate( page: params[ :page ])
      end
      format.xls do # no pagination for CSV format
        @dcc_codes = DccCode.filter( filter_params )
        set_header( :xls, 'dcc_codes.csv' )
      end
    end
  end

  # GET /fncs/1

  def show
  end

  # GET /fncs/new

  def new
    @dcc_code = DccCode.new
  end

  # GET /fncs/1/edit

  def edit
  end

  # POST /fncs

  def create
    @dcc_code = DccCode.new( dcc_code_params )
    respond_to do |format|
      if @dcc_code.save
        format.html { redirect_to @dcc_code, notice: t( 'dcc_codes.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /fncs/1

  def update
    respond_to do |format|
      if @dcc_code.update( dcc_code_params )
        format.html { redirect_to @dcc_code, notice: t( 'dcc_codes.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /fncs/1

  def destroy
    @dcc_code.destroy
    respond_to do |format|
      format.html { redirect_to dcc_codes_url, notice: t( 'dcc_codes.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_dcc_code
      @dcc_code = DccCode.find( params[:id] )
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def dcc_code_params
      params.require( :dcc_code ).permit( :code, :label, :active, :master, :standard, :heading, :note )
    end

    def filter_params
      params.slice( :as_code, :as_desc ).clean_up
    end

end
