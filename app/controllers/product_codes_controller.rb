class ProductCodesController < ApplicationController
  require 'csv'
  include ControllerMethods
  initialize_feature FEATURE_ID_PRODUCT_CODES, FEATURE_ACCESS_VIEW
  before_action :set_product_code, only: [ :show, :edit, :update, :destroy ]

  # GET /fncs

  def index
    @filter_fields = filter_params
    respond_to do |format|
      format.html do
        @product_codes = ProductCode.filter( filter_params ).paginate( page: params[ :page ])
      end
      format.xls do # no pagination for CSV format
        @product_codes = ProductCode.filter( filter_params )
        set_header( :xls, 'product_codes.csv' )
      end
    end
  end

  # GET /fncs/1

  def show
  end

  # GET /fncs/new

  def new
    @product_code = ProductCode.new
  end

  # GET /fncs/1/edit

  def edit
  end

  # POST /fncs

  def create
    @product_code = ProductCode.new( product_code_params )
    respond_to do |format|
      if @product_code.save
        format.html { redirect_to @product_code, notice: t( 'product_codes.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /fncs/1

  def update
    respond_to do |format|
      if @product_code.update( product_code_params )
        format.html { redirect_to @product_code, notice: t( 'product_codes.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /fncs/1

  def destroy
    @product_code.destroy
    respond_to do |format|
      format.html { redirect_to product_codes_url, notice: t( 'product_codes.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_product_code
      @product_code = ProductCode.find( params[:id] )
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def product_code_params
      params.require( :product_code ).permit( :code, :label, :active, :master, :standard, :heading, :note )
    end

    def filter_params
      params.slice( :as_code, :as_desc ).clean_up
    end

end
