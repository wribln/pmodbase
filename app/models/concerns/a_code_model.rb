require 'active_support/concern'
module ACodeModel
  extend ActiveSupport::Concern

  included do

    validates :code,
      presence: true

    validates :label,
      presence: true,
      length: { maximum: MAX_LENGTH_OF_LABEL }

    validate :only_one_master

    scope :std_order,   -> { order( code: :asc, master: :desc )}
    scope :active_only, -> { where active: true }
    scope :as_code, -> ( c ){ where( 'code  LIKE ?',  "#{ c }%" )}
    scope :as_desc, -> ( l ){ where( 'label LIKE ?', "%#{ l }%" )}

  end

  # overwrite write accessors to ensure that text fields do not contain
  # any redundant blanks 

  def code=( text )
    write_attribute( :code, AppHelper.clean_up( text ))
  end

  def label=( text )
    write_attribute( :label, AppHelper.clean_up( text ))
  end

  # note: use '#{ self.class.table_name }' instead of 'code_modules' if you want
  #       to use table-specific error messages

  # check if there is only a single master record defined for this code

  def only_one_master
    if master then
      if self.class.where( code: code, master: TRUE ).where.not( id: id ).count > 0 then
        errors.add( :base, I18n.t( 'a_code_modules.msg.too_many_masters' ))
      end
    end
  end

  # return a combination of code and label for dropdown list boxes (select in HTML)

  def code_and_label
    code + ' - ' + label
  end

end
