require './lib/assets/app_helper.rb'
class PhaseCode < ActiveRecord::Base
  include ApplicationModel
  include Filterable

  belongs_to :siemens_phase, -> { readonly }, inverse_of: :phase_codes

  validates :code,
    presence: true,
    uniqueness: true,
    format: { with: Regexp.union( /\A%!\z/,/\A%[A-Z0-9.\-]+\z/), message: I18n.t( 's_code_modules.msg.bad_code_syntax' )},
    length: { maximum: MAX_LENGTH_OF_CODE }

  validates :label,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  validates :acro,
    allow_blank: true,
    uniqueness: { case_sensitive: false },
    length: { maximum: MAX_LENGTH_OF_CODE }

  validate :acro_not_same_as_code
  validate :code_has_prefix

  validates :siemens_phase_id,
    presence: true

  validate :given_siemens_phase_exists

  validates :level,
    presence: true,
    numericality: { only_integer: true }

  default_scope { order( acro: :asc )}
  scope :as_code, -> ( a ){ 
      where( 'code LIKE ? ESCAPE \'+\'',
        if has_code_prefix( abbr ) then
          "#{ sanitize_sql_like( a,'+' )}%"
        else
          "#{ sanitize_sql_like( code_prefix, '+')}#{ a }%"
        end )
    }
  scope :as_abbr, -> ( a ){ where( 'acro LIKE ?',   "#{ a }%"  )}
  scope :as_desc, -> ( d ){ where( 'label LIKE ?', "%#{ d }%" )}

  # add code_model features

  class << self
    attr_accessor :code_prefix
  end
 
  @code_prefix = '%'

  def self.has_code_prefix( c )
    c && c[ 0 ] == @code_prefix
  end

  # make sure the given code includes the class prefix
  
  def code_has_prefix
    errors.add( :code, I18n.t( "s_code_modules.msg.bad_code_format", prefix: @code_prefix )) \
    unless self.class.has_code_prefix( code )
  end

  # phase code and acronym must not be the same

  def acro_not_same_as_code
    if acro.present? && code.present?
      errors.add( :acro, I18n.t( 'phase_codes.msg.acro_eq_code' )) \
        unless acro != code
    end
  end

  # check if related record exists

  def given_siemens_phase_exists
    if siemens_phase_id.present?
      errors.add( :siemens_phase_id, I18n.t( 'phase_codes.msg.bad_s_phase' )) \
        unless SiemensPhase.exists?( siemens_phase_id )
    end
  end

  # overwrite write accessors to ensure that text fields do not contain
  # any redundant blanks 

  def code=( text )
    write_attribute( :code, AppHelper.clean_up( text ))
  end

  def acro=( text )
    write_attribute( :acro, AppHelper.clean_up( text ))
  end

  def label=( text )
    write_attribute( :label, AppHelper.clean_up( text ))
  end

  # return a combination of code and label for dropdown list boxes (select in HTML)

  def code_and_label
    code << ' - ' << label
  end

end
