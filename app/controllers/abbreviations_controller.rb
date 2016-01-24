class AbbreviationsController < ApplicationController
  require 'csv'
  include ControllerMethods

  initialize_feature FEATURE_ID_ABBREVIATIONS, FEATURE_ACCESS_INDEX
  
  before_action :set_abbreviation, only:  [ :show, :edit, :update, :destroy ]

  # GET /abbreviations

  def index
    @filter_fields = filter_params
    respond_to do |format|
      format.html do
        @abbreviations = Abbreviation.filter( filter_params ).paginate( page: params[ :page ])
      end
      format.xls do # no pagination for CSV format
        @abbreviations = Abbreviation.filter( filter_params )
        set_header( :xls, 'abbreviations.csv' )
      end
    end
  end

  # GET /abbreviations/1

  def show
  end

  # GET /abbreviations/new

  def new
    @abbreviation = Abbreviation.new
  end

  # GET /abbreviations/1/edit

  def edit
  end

  # POST /abbreviations

  def create
    @abbreviation = Abbreviation.new( abbreviation_params )
    respond_to do |format|
      if @abbreviation.save
        format.html { redirect_to @abbreviation, notice: t( 'abbreviations.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /abbreviations/1

  def update
    respond_to do |format|
      if @abbreviation.update(abbreviation_params)
        format.html { redirect_to @abbreviation, notice: t( 'abbreviations.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /abbreviations/1

  def destroy
    @abbreviation.destroy
    respond_to do |format|
      format.html { redirect_to abbreviations_url, notice: t( 'abbreviations.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_abbreviation
      @abbreviation = Abbreviation.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def abbreviation_params
      params.require( :abbreviation ).permit( :id, :code, :description, :sort_code )
    end

    def filter_params
      params.slice( :ff_id, :ff_code, :ff_desc ).clean_up
    end      

end
