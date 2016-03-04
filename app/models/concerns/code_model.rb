require 'active_support/concern'
module CodeModel
  extend ActiveSupport::Concern

  included do

    # I need a class level instance variable containing the code prefix
    # which is unique for each code
    
    class_attribute :code_prefix

    validates :code,
      presence: true,
      format: { with: /\A.[A-Z0-9.\-]+\z/, message: I18n.t( 'code_modules.msg.bad_code_syntax' )},
      length: { maximum: MAX_LENGTH_OF_CODE }

    validate :code_has_prefix

    validates :label,
      presence: true,
      length: { maximum: MAX_LENGTH_OF_LABEL }

    validate :flag_combinations
    validate :only_one_master

    default_scope { order( code: :asc, master: :desc )}
    scope :active_only, -> { where active: true }
    scope :as_code, -> ( c ){ where( 'code  LIKE ?',  has_code_prefix( c ) ? "#{ c }%" : "#{ code_prefix }#{ c }%" )}
    scope :as_desc, -> ( l ){ where( 'label LIKE ?', "%#{ l }%" )}

  end

  class_methods do

    def has_code_prefix( c )
      c && c[ 0 ] == code_prefix
    end

  end

  # overwrite write accessors to ensure that text fields do not contain
  # any redundant blanks 

  def code=( text )
    write_attribute( :code, AppHelper.clean_up( text, MAX_LENGTH_OF_CODE ))
  end

  def label=( text )
    write_attribute( :label, AppHelper.clean_up( text, MAX_LENGTH_OF_LABEL ))
  end

  # note: use '#{ self.class.table_name }' instead of 'code_modules' if you want
  #       to use table-specific error messages

  # make sure the given code includes the class prefix
  
  def code_has_prefix
    errors.add( :code, I18n.t( "code_modules.msg.bad_code_format", prefix: self.class.code_prefix )) \
    unless self.class.has_code_prefix( code )
  end

  # check if flag combinations are valid

  def flag_combinations
    errors.add( :heading, I18n.t( 'code_modules.msg.bad_h_m_combo' )) \
      if heading && master
    errors.add( :heading, I18n.t( 'code_modules.msg.bad_h_a_combo' )) \
      if heading && active 
  end

  # check if there is only a single master record defined for this code

  def only_one_master
    if master then
      if self.class.where( code: code, master: TRUE ).where.not( id: id ).count > 0 then
        errors.add( :base, I18n.t( 'code_modules.msg.too_many_masters' ))
      end
    end
  end

  # return a combination of code and label for dropdown list boxes (select in HTML)

  def code_and_label
    code + ' - ' + label
  end

end
