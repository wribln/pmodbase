class FunctionCodesController < ApplicationController
  require 'csv'
  include ControllerMethods
  initialize_feature FEATURE_ID_FUNCTION_CODES, FEATURE_ACCESS_VIEW
  before_action :set_function_code, only: [ :show, :edit, :update, :destroy ]

  # GET /fncs

  def index
    @filter_fields = filter_params
    respond_to do |format|
      format.html do
        @function_codes = FunctionCode.filter( @filter_fields ).paginate( page: params[ :page ])
      end
      format.xls do # no pagination for CSV format
        @function_codes = FunctionCode.filter( @filter_fields )
        set_header( :xls, 'function_codes.csv' )
      end
    end
  end

  # GET /fncs/1

  def show
  end

  # GET /fncs/new

  def new
    @function_code = FunctionCode.new
  end

  # GET /fncs/1/edit

  def edit
  end

  # POST /fncs

  def create
    @function_code = FunctionCode.new( function_code_params )
    respond_to do |format|
      if @function_code.save
        format.html { redirect_to @function_code, notice: t( 'function_codes.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /fncs/1

  def update
    respond_to do |format|
      if @function_code.update( function_code_params )
        format.html { redirect_to @function_code, notice: t( 'function_codes.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /fncs/1

  def destroy
    @function_code.destroy
    respond_to do |format|
      format.html { redirect_to function_codes_url, notice: t( 'function_codes.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_function_code
      @function_code = FunctionCode.find( params[:id] )
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def function_code_params
      params.require( :function_code ).permit( :code, :label, :active, :master, :standard, :heading, :note )
    end

    def filter_params
      params.slice( :as_code, :as_desc ).clean_up
    end

end
