class UnitNamesController < ApplicationController
  require 'csv'
  include ControllerMethods

  initialize_feature FEATURE_ID_UNIT_NAMES, FEATURE_ACCESS_INDEX

  before_action :set_unit_name,  only: [:show, :edit, :update, :destroy]

  # GET /unit_names

  def index
    @unit_names = UnitName.all
    respond_to do |format|
      format.html
      format.xls { set_header( :xls, 'unit_names.csv' )}
    end      
  end

  # GET /unit_names/1

  def show
  end

  # GET /unit_names/new

  def new
    @unit_name = UnitName.new
  end

  # GET /unit_names/1/edit

  def edit
  end

  # POST /unit_names

  def create
    @unit_name = UnitName.new( unit_name_params )
    respond_to do |format|
      if @unit_name.save
        format.html { redirect_to @unit_name, notice: t( 'unit_names.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /unit_names/1

  def update
    respond_to do |format|
      if @unit_name.update(unit_name_params)
        format.html { redirect_to @unit_name, notice: t( 'unit_names.msg.edit_ok' ) }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /unit_names/1

  def destroy
    @unit_name.destroy
    respond_to do |format|
      format.html { redirect_to unit_names_url, notice: t( 'unit_names.msg.delete_ok' ) }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
  
    def set_unit_name
      @unit_name = UnitName.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def unit_name_params
      params.require( :unit_name ).permit( :code, :label )
    end

end
