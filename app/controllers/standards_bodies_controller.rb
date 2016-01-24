class StandardsBodiesController < ApplicationController
  require 'csv'
  include ControllerMethods

  initialize_feature FEATURE_ID_STANDARDS_BODIES, FEATURE_ACCESS_INDEX

  before_action :set_standards_body, only: [:show, :edit, :update, :destroy]

  # GET /standards_bodies

  def index
    @standards_bodies = StandardsBody.all.order( :code )
    respond_to do |format|
      format.html
      format.xls { set_header( :xls, 'standards_bodies.csv' )}
    end
  end

  # GET /standards_bodies/1

  def show
  end

  # GET /standards_bodies/new

  def new
    @standards_body = StandardsBody.new
  end

  # GET /standards_bodies/1/edit

  def edit
  end

  # POST /standards_bodies

  def create
    @standards_body = StandardsBody.new(standards_body_params)

    respond_to do |format|
      if @standards_body.save
        format.html { redirect_to @standards_body, notice: t( 'standards_bodies.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /standards_bodies/1

  def update
    respond_to do |format|
      if @standards_body.update(standards_body_params)
        format.html { redirect_to @standards_body, notice: t( 'standards_bodies.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /standards_bodies/1

  def destroy
    @standards_body.destroy
    respond_to do |format|
      format.html { redirect_to standards_bodies_url, notice: t( 'standards_bodies.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
  
    def set_standards_body
      @standards_body = StandardsBody.find( params[:id] )
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def standards_body_params
      params.require( :standards_body ).permit( :code, :description )
    end

end
