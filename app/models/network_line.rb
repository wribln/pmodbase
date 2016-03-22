require './lib/assets/app_helper.rb'
class NetworkLine < ActiveRecord::Base
  include ApplicationModel
  include LocationCodeCheck
  include Filterable
  
  belongs_to :location_code, -> { readonly }, inverse_of: :network_lines
  has_many   :network_stops, inverse_of: :network_line
  has_many   :network_stations, through: :network_stops

  validates :code,
    presence: true,
    uniqueness: true,
    length: { maximum: MAX_LENGTH_OF_CODE }

  validates :label,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  validates :note,
    length: { maximum: MAX_LENGTH_OF_NOTE }

  validates :seqno,
    presence: true,
    numericality: { only_integer: true }

  validate :given_location_code_exists

  # scopes

  default_scope { order( seqno: :asc, code: :asc )}
  scope :ff_id,     ->( i ){ where( id: i )}
  scope :ff_code,   ->( c ){ where( 'code LIKE ?',  "#{ c }%" )}
  scope :ff_label,  ->( l ){ where( 'label LIKE ?', "%#{ l }%")}

  # overwrite write accessors to ensure that text fields do not contain
  # any redundant blanks 

  def code=( text )
    write_attribute( :code, AppHelper.clean_up( text, MAX_LENGTH_OF_CODE ))
  end

  def label=( text )
    write_attribute( :label, AppHelper.clean_up( text, MAX_LENGTH_OF_LABEL ))
  end

  def code_and_label
    code + ' - ' + label
  end

end
