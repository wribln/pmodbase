require './lib/assets/app_helper.rb'
class CountryName < ActiveRecord::Base
  include ApplicationModel
  include Filterable

  has_many :region_names, dependent: :destroy, inverse_of: :country_name
  has_many :holidays,     dependent: :destroy, inverse_of: :country_name

  validates :code,
    uniqueness: true,
    length: { maximum: MAX_LENGTH_OF_CODE },
    presence: true

  validates :label,
    length: { maximum: MAX_LENGTH_OF_LABEL },
    presence: true

  default_scope { order( code: :asc )}
  scope :as_abbr, ->  ( abbr ){ where( 'code  LIKE ?',  "#{ abbr }%" )}
  scope :as_desc, ->  ( desc ){ where( 'label LIKE ?', "%#{ desc }%" )}
  scope :ff_id, ->    ( id   ){ where id: id }
  scope :ff_code, ->  ( code ){ as_abbr( code ) }
  scope :ff_label, -> ( desc ){ as_desc( desc ) }

  def code=( text )
    write_attribute( :code, AppHelper.clean_up( text, MAX_LENGTH_OF_CODE ))
  end

  def label=( text )
    write_attribute( :label, AppHelper.clean_up( text, MAX_LENGTH_OF_LABEL ))
  end

end
