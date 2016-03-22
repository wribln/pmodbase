class NetworkStationsController < ApplicationController
  require 'csv'
  include ControllerMethods
  initialize_feature FEATURE_ID_NW_STATIONS, FEATURE_ACCESS_VIEW
  before_action :set_network_station, only: [:show, :edit, :update, :destroy]

  # GET /nsts

  def index
    @filter_fields = filter_params
    @network_lines = NetworkLine.all.collect{ |l| [ l.code_and_label, l.id ]}
    # when selecting a specific line, order by stop_no on that line
    sort_order = @filter_fields.has_key?( :ff_line ) ? 'network_stops.stop_no' : :code
    respond_to do |format|
      format.html do
        @network_stations = NetworkStation.includes( :network_stops ).filter( @filter_fields ).order( sort_order ).paginate( page: params[ :page ])
      end
      format.xls do
        @network_stations = NetworkStation.includes( :network_stops, :network_lines ).filter( @filter_fields ).order( sort_order )
        @hashtag_station_codes = Hashtag.where( feature_id: FEATURE_ID_NW_STATIONS ).pluck( :code )
        @hashtag_stop_codes = Hashtag.where( feature_id: FEATURE_ID_NW_STOPS ).pluck( :code )
        set_header( :xls, 'network_stations.csv' )
      end
    end
  end

  # GET /nsts/1

  def show
  end

  # GET /nsts/new

  def new
    @network_station = NetworkStation.new
  end

  # GET /nsts/1/edit

  def edit
  end

  # POST /nsts
  
  def create
    @network_station = NetworkStation.new( network_station_params )
    respond_to do |format|
      if @network_station.save
        format.html { redirect_to @network_station, notice: t( 'network_stations.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /nsts/1
  # - remove 'template' from returned parameters because non-numeric
  #   hash-keys there cause "Unpermitted parameters" errors and prohibit
  #   saving any permission records (RoR 4.1.6)
  # - Note: 'template' entry may not exist in test environment, hence try
  #   is inserted

  def update
    respond_to do |format|
      params[ :network_station ][ :network_stops_attributes ].try( :delete, 'template' )      
      if @network_station.update( network_station_params )
        format.html { redirect_to @network_station, notice: t( 'network_stations.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /nsts/1

  def destroy
    @network_station.destroy
    respond_to do |format|
      format.html { redirect_to network_stations_url, notice: t( 'network_stations.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_network_station
      @network_station = NetworkStation.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def network_station_params
      params.require( :network_station ).permit(
        :code, :alt_code, :curr_name, :prev_name, :transfer, :note,
        network_stops_attributes: 
          [ :id, :_destroy, :stop_no, :code, :location_code_id, :note, :network_line_id ])
    end

    def filter_params
      params.slice( :ff_code, :ff_line, :ff_note, :ff_label ).clean_up
    end

end
