require './lib/assets/app_helper.rb'
class NetworkStation < ActiveRecord::Base
  include ApplicationModel
  include Filterable

  has_many :network_stops, inverse_of: :network_station
  has_many :network_lines, through: :network_stops
  accepts_nested_attributes_for :network_stops, allow_destroy: true
  validates_associated :network_stops

  validates :code,
    presence: true,
    uniqueness: true,
    length: { maximum: MAX_LENGTH_OF_CODE }

  validates :alt_code,
    length: { maximum: MAX_LENGTH_OF_CODE }

  validates :curr_name, :prev_name,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  validates :note,
    length: { maximum: MAX_LENGTH_OF_DESCRIPTION }

  validate :transfer_stop_relation

  scope :ff_code,   ->( c ){ where( 'code LIKE ? or alt_code LIKE ?', "#{ c }%", "%#{ c }%" )}
  scope :ff_xfer,   ->( f ){ where  transfer:( f == '0' )}
  scope :ff_note,   ->( t ){ where( 'note LIKE ?', "%#{ t }%" )}
  scope :ff_label,  ->( l ){ where( 'curr_name LIKE ? or prev_name LIKE ?', "%#{ l }%", "%#{ l }%")}
  scope :ff_line,   ->( l ){ self.includes( :network_stops ).where( network_stops: { network_line_id: l }) }
  scope :w_o_stop,  ->{ self.includes( :network_stops ).where( network_stops: { id: nil }) }
  
  class << self
    alias :as_abbr :ff_code
    alias :as_desc :ff_label
  end

  # ensure that transfer flag is not cleared when there are more than
  # a single stop assigned to this station; also, make sure not more
  # than one stop is assigned to non-transfer stations

  def transfer_stop_relation
    if self.network_stops.count > 1 && not( self.transfer )then
      errors.add( :transfer, I18n.t( 'network_stations.msg.xfer_check' )) \
    end
  end

  # overwrite write accessors to ensure that text fields do not contain
  # any redundant blanks 

  def code=( text )
    write_attribute( :code, AppHelper.clean_up( text ))
  end

  def alt_code=( text )
    write_attribute( :alt_code, AppHelper.clean_up( text ))
  end

  def curr_name=( text )
    write_attribute( :curr_name, AppHelper.clean_up( text ))
  end

  def prev_name=( text )
    write_attribute( :prev_name, AppHelper.clean_up( text ))
  end

end
