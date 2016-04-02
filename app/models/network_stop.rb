class NetworkStop < ActiveRecord::Base
  include ApplicationModel
  include LocationCodeCheck

  belongs_to :location_code, -> { readonly }, inverse_of: :network_stops
  belongs_to :network_station, inverse_of: :network_stops
  belongs_to :network_line, inverse_of: :network_stops

  validates :stop_no,
    presence: false,
    numericality: { only_integer: true }

  validates :network_line_id,
    presence: true

  validates :code,
    length: { maximum: MAX_LENGTH_OF_CODE }

  validates :note,
    length: { maximum: MAX_LENGTH_OF_NOTE }

  validate :given_network_line_exists
  validate :given_network_station_exists
  validate :stop_count_in_station, on: :create

  scope :order_by_line_seqno, -> { includes( :network_line ).order ( 'network_lines.seqno' )} 

  def given_network_line_exists
    if self.network_line_id.present?
      errors.add( :network_line_id, I18n.t( 'network_stops.msg.bad_nw_line' )) \
        unless NetworkLine.exists?( self.network_line_id )
    end
  end

  def given_network_station_exists
    if self.network_station_id.present?
      errors.add( :network_station_id, I18n.t( 'network_stops.msg.bad_nw_stn' )) \
        unless NetworkStation.exists?( self.network_station_id )
    end
  end

  def stop_count_in_station
    if self.network_station_id.present?
      errors.add( :base, I18n.t( 'network_stops.msg.bad_no_stops' )) \
        unless self.network_station.transfer || self.network_station.network_stops.count < 1
    end
  end

end