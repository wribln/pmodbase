class HolidaysController < ApplicationController
  require 'csv'
  include ControllerMethods

  initialize_feature FEATURE_ID_HOLIDAYS, FEATURE_ACCESS_VIEW

  before_action :set_holiday,    only: [ :show, :edit, :update, :destroy, :add ]
  before_action :set_selections, only: [ :edit, :new, :create, :update, :add ]

  # GET /holidays

  def index
    @filter_fields = filter_params
    respond_to do |format|
      format.html do
        @country_filter = CountryName.joins( :holidays ).distinct.order( :code )
        @year_filter = Holiday.select( :year_period ).distinct.reorder( :year_period )
        @holidays = Holiday.includes( :country_name ).filter( filter_params ).paginate( page: params[ :page ])
      end
      format.xls do # no filter selections, pagination for CSV format
        @holidays = Holiday.includes( :country_name ).filter( filter_params )
        set_header( :xls, 'holidays.csv' )
      end
    end
  end

  # GET /holidays/1

  def show
  end

  # GET /holidays/1/add

  def add
    @holiday.id = nil
  end

  # GET /holidays/new

  def new
    @holiday = Holiday.new
  end

  # GET /holidays/1/edit

  def edit
  end

  # POST /holidays

  def create
    @holiday = Holiday.new( holiday_params )
    respond_to do |format|
      if @holiday.save
        format.html { redirect_to @holiday, notice: t( 'holidays.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /holidays/1

  def update
    respond_to do |format|
      if @holiday.update( holiday_params )
        format.html { redirect_to @holiday, notice: t( 'holidays.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /holidays/1

  def destroy
    @holiday.destroy
    respond_to do |format|
      format.html { redirect_to holidays_url, notice: t( 'holidays.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
  
    def set_holiday
      @holiday = Holiday.includes( :country_name ).find( params[ :id ])
    end

    def set_selections
      @country_names = CountryName.all
      @region_names = RegionName.all
    end

    # Never trust parameters from the scary internet, only allow the white list through.
  
    def holiday_params
      params.require( :holiday ).permit( :id, :date_from, :date_until, :country_name_id, :region_name_id, :description, :work )
    end

    def filter_params
      params.slice( :ff_id, :ff_country, :ff_year, :ff_desc ).clean_up
    end

end
