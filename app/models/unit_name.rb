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

  default_scope { order( 'LOWER(code) ASC' )}
  scope :as_abbr,    -> ( a ){ where( 'code  LIKE ?',  "#{ a }%" )}
  scope :as_desc,    -> ( d ){ where( 'label LIKE ?', "%#{ d }%" )}

  # overwrite write accessors to ensure that text fields do not contain
  # any redundant blanks

  def code=( text )
    write_attribute( :code, AppHelper.clean_up( text, MAX_LENGTH_OF_CODE ))
  end

  def label=( text )
    write_attribute( :label, AppHelper.clean_up( text, MAX_LENGTH_OF_LABEL ))
  end

  # provide combination of unit and name

  def unit_name_and_label
    "#{ code } (#{ label })"
  end

end
