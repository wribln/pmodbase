require "./lib/assets/app_helper.rb"
class RegionName < ActiveRecord::Base
  include ApplicationModel
  include CountryNameCheck
  include Filterable

  belongs_to :country_name, -> { readonly }, inverse_of: :region_names
  has_many   :holidays, dependent: :destroy, inverse_of: :region_name

  validates :country_name_id,
    presence: true

  validate :given_country_name_exists

  validates :code,
    length: { maximum: MAX_LENGTH_OF_CODE },
    presence: true,
    uniqueness: { scope: :country_name_id }

  validates :label,
    length: { maximum: MAX_LENGTH_OF_LABEL },
    presence: true

  default_scope { order( :country_name_id, :code )}
  scope :as_abbr,    -> ( abbr ){ where( 'code  LIKE ?',  "#{ abbr }%" )}
  scope :as_desc,    -> ( desc ){ where( 'label LIKE ?', "%#{ desc }%" )}
  scope :ff_id,      -> ( id   ){ where id: id }
  scope :ff_country, -> ( cnty ){ where country_name: cnty }
  scope :ff_code,    -> ( code ){ as_abbr( code )}
  scope :ff_label,   -> ( desc ){ as_desc( desc )}

  # overwrite write accessors to ensure that text fields do not contain
  # any redundant blanks

  def code=( text )
    write_attribute( :code, AppHelper.clean_up( text, MAX_LENGTH_OF_CODE ))
  end

  def label=( text )
    write_attribute( :label, AppHelper.clean_up( text, MAX_LENGTH_OF_LABEL ))
  end

  # provide labels with id

  def label_with_id
    text_and_id( :label )
  end

  def country_code_with_id
    assoc_text_and_id( :country_name, :code )
  end

  def country_code
    "#{ country_name.code }"
  end

end
