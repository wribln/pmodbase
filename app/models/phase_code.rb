require './lib/assets/app_helper.rb'
class PhaseCode < ActiveRecord::Base
  include ApplicationModel
  include Filterable

  belongs_to :siemens_phase, -> { readonly }, inverse_of: :phase_codes

  validates :code,
    presence: true,
    uniqueness: true,
    length: { maximum: MAX_LENGTH_OF_CODE }

  validates :label,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  validates :acro,
    allow_blank: true,
    uniqueness: { case_sensitive: false },
    length: { maximum: MAX_LENGTH_OF_CODE }

  validate :acro_not_same_as_code

  validates :siemens_phase_id,
    presence: true

  validate :given_siemens_phase_exists

  validates :level,
    presence: true,
    numericality: { only_integer: true }

  default_scope { order( acro: :asc )}
  scope :as_abbr, -> ( abbr ){ where( 'acro LIKE ?', "#{ abbr }%" )}
  scope :as_desc, -> ( desc ){ where( 'label LIKE ?', "%#{ desc }%" )}

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
    write_attribute( :code, AppHelper.clean_up( text, MAX_LENGTH_OF_CODE ))
  end

  def acro=( text )
    write_attribute( :acro, AppHelper.clean_up( text, MAX_LENGTH_OF_CODE ))
  end

  def label=( text )
    write_attribute( :label, AppHelper.clean_up( text, MAX_LENGTH_OF_LABEL ))
  end


end
