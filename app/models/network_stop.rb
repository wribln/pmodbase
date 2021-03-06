class NetworkStop < ActiveRecord::Base
  include ApplicationModel

  belongs_to :location_code, -> { readonly }, optional: true, inverse_of: :network_stops
  belongs_to :network_station,                                inverse_of: :network_stops
  belongs_to :network_line,                                   inverse_of: :network_stops

  validates :stop_no,
    presence: false,
    numericality: { only_integer: true }

  validates :network_line,
    presence: true

  validates :network_station,
    presence: true
    
  validates :location_code,
    presence: true, if: Proc.new{ |me| me.location_code_id.present? }

  validates :code,
    length: { maximum: MAX_LENGTH_OF_CODE }

  validates :note,
    length: { maximum: MAX_LENGTH_OF_NOTE }

  validate :stop_count_in_station, on: :create

  scope :order_by_line_seqno, -> { includes( :network_line ).order ( 'network_lines.seqno' )} 

  def stop_count_in_station
    return if errors.include?( :network_station_id )
    if self.network_station_id.present?
      errors.add( :base, I18n.t( 'network_stops.msg.bad_no_stops' )) \
        unless self.network_station.transfer || self.network_station.network_stops.count < 1
    end
  end

end
