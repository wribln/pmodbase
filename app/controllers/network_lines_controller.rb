class NetworkLinesController < ApplicationController

  initialize_feature FEATURE_ID_NW_LINES, FEATURE_ACCESS_VIEW
  before_action :set_network_line, only: [:show, :edit, :update, :destroy]

  # GET /nlns

  def index
    @filter_fields = filter_params
    @network_lines = NetworkLine.filter( @filter_fields )

    # collect stats

    @total_lines = 0
    @total_stations = 0
    @total_stops = 0
    @hashline_stats = Hashtag.new_stats
    @hashstop_stats = Hashtag.new_stats
    @hashstation_stats = Hashtag.new_stats
    NetworkLine.filter( @filter_fields ).each do |nwl|
      @total_lines += 1
      Hashtag.collect_hashstats( nwl.note, @hashline_stats )
      nwl.network_stations.each do |nws|
        @total_stations += 1
        Hashtag.collect_hashstats( nws.note, @hashstation_stats )
      end
      nwl.network_stops.each do |nws|
        @total_stops += 1
        Hashtag.collect_hashstats( nws.note, @hashstop_stats )
      end
    end
    @hashline_labels = Hashtag.where( feature_id: FEATURE_ID_NW_LINES ).pluck( :code, :label )
    @hashstop_labels = Hashtag.where( feature_id: FEATURE_ID_NW_STOPS ).pluck( :code, :label )
    @hashstation_labels = Hashtag.where( feature_id: FEATURE_ID_NW_STATIONS ).pluck( :code, :label )

    # collect statistics for all stations w/o line association

    @total_orphans = 0
    @hashorphan_stats = Hashtag.new_stats
    NetworkStation.w_o_stop.each do |nws|
      @total_orphans += 1
      Hashtag.collect_hashstats( nws.note, @hashorphan_stats )
    end

  end

  # GET /nlns/1

  def show
  end

  # GET /nlns/new

  def new
    @network_line = NetworkLine.new
  end

  # GET /nlns/1/edit

  def edit
  end

  # POST /nlns

  def create
    @network_line = NetworkLine.new( network_line_params )
    respond_to do |format|
      if @network_line.save
        format.html { redirect_to @network_line, notice: I18n.t( 'network_lines.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /nlns/1

  def update
    respond_to do |format|
      if @network_line.update(network_line_params)
        format.html { redirect_to @network_line, notice: I18n.t( 'network_lines.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /nlns/1

  def destroy
    @network_line.destroy
    respond_to do |format|
      format.html { redirect_to network_lines_url, notice: I18n.t( 'network_lines.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_network_line
      @network_line = NetworkLine.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def network_line_params
      params.require( :network_line ).permit( :code, :label, :seqno, :location_code_id, :note )
    end

    def filter_params
      params.slice( :ff_id, :ff_code, :ff_label ).clean_up
    end

end
