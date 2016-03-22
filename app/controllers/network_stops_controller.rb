class NetworkStopsController < ApplicationController
  include ControllerMethods
  initialize_feature FEATURE_ID_NW_STOPS, FEATURE_ACCESS_VIEW
  before_action :set_network_stop, only: [:show, :edit, :update, :destroy]

  # GET /nsos

  def index
    @network_stops = NetworkStop.all.order( :network_line_id, :stop_no)
  end

  # GET /nsos/1

  def show
  end

  # GET /nsos/new

  def new
    @network_stop = NetworkStop.new
  end

  # GET /nsos/1/edit

  def edit
  end

  # POST /nsos

  def create
    @network_stop = NetworkStop.new( network_stop_params )
    respond_to do |format|
      if @network_stop.save
        format.html { redirect_to @network_stop, notice: t( 'network_stops.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /nsos/1

  def update
    respond_to do |format|
      if @network_stop.update(network_stop_params)
        format.html { redirect_to @network_stop, notice: t( 'network_stops.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /nsos/1

  def destroy
    @network_stop.destroy
    respond_to do |format|
      format.html { redirect_to network_stops_url, notice: t( 'network_stops.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_network_stop
      @network_stop = NetworkStop.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def network_stop_params
      params.require( :network_stop ).permit( :code, :stop_no, :code, :note,
        :location_code_id, :network_station_id, :network_line_id )
    end
end
