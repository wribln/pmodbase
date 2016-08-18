require "./lib/assets/app_helper.rb"
class RegionName < ActiveRecord::Base
  include ApplicationModel
  include ActiveModelErrorsAdd
  include Filterable

  belongs_to :country_name, -> { readonly }, inverse_of: :region_names
  has_many   :holidays, dependent: :destroy, inverse_of: :region_name

  validates :country_name,
    presence: true

  validates :code,
    length: { maximum: MAX_LENGTH_OF_CODE },
    presence: true,
    uniqueness: { scope: :country_name_id }

  validates :label,
    length: { maximum: MAX_LENGTH_OF_LABEL },
    presence: true

  set_trimmed :code, :label

  default_scope { order( :country_name_id, :code )}
  scope :as_abbr,    -> ( a ){ where( 'code  LIKE ?',  "#{ a }%" )}
  scope :as_desc,    -> ( d ){ where( 'label LIKE ?', "%#{ d }%" )}
  scope :ff_id,      -> ( i ){ where id: i }
  scope :ff_country, -> ( c ){ where country_name: c }
  class << self;
    alias :ff_code  :as_abbr
    alias :ff_label :as_desc
  end

  # provide labels with id

  def label_with_id
    text_and_id( :label )
  end

  def country_code
    "#{ country_name.code }"
  end

end
