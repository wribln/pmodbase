require './lib/assets/app_helper.rb'
class UnitName < ActiveRecord::Base
  include ApplicationModel
  include Filterable

  validates :code,
    length: { maximum: MAX_LENGTH_OF_CODE },
    presence: true

    validates :label,
    length: { maximum: MAX_LENGTH_OF_LABEL },
    presence: true

  set_trimmed :code, :label

  default_scope { order( UnitName.arel_table[ :code ].lower.asc )}
  scope :as_abbr,    -> ( a ){ where( 'code  LIKE ?',  "#{ a }%" )}
  scope :as_desc,    -> ( d ){ where( 'label LIKE ?', "%#{ d }%" )}

  # provide combination of unit and name

  def unit_name_and_label
    "#{ code } (#{ label })"
  end

end
