require './lib/assets/app_helper.rb'
class Responsibility < ActiveRecord::Base
  include ApplicationModel
  include Filterable
  include PersonCheck
  include GroupCheck

  belongs_to :person, inverse_of: :responsibilities
  belongs_to :group, inverse_of: :responsibilities

  validates :seqno,
    presence: true,
    numericality: { only_integer: true }

  validates :description,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_DESCRIPTION }

  # person_id can be 0 ("N.N."), or must exist

  validates :person_id,
    presence: true

  validate :given_person_exists_or_is_zero

  validates :group_id,
    presence: true

  # The module only checks here if the given group exists but it should
  # also be an active participant: This is somewhat controlled by the
  # list of possible groups in the controller, but may have to be enforced
  # later if needed on the module level. 

  validate :given_group_exists

  scope :ff_group,  -> ( group  ){ where group_id: group }
  scope :ff_resp,   -> ( resp   ){ where( 'description like ?', "%#{ resp }%" )}
  scope :ff_email,  -> ( email  ){ where( 'people.email like ?', "%#{ email }%" ).references( :people )}
  scope :ff_name,   -> ( name   ){ where( '( people.formal_name LIKE ? ) OR ( people.informal_name LIKE ? )', "%#{ name }%", "%#{ name }%" ).references( :people )}
  scope :ff_dept,   -> ( dept   ){ where( 'contact_infos.department like ?', "#{ dept }%" ).references( :contact_infos )}

  # overwrite write accessors to ensure that text fields do not contain
  # any redundant blanks

  def description=( text )
    write_attribute( :description, AppHelper.clean_up( text, MAX_LENGTH_OF_DESCRIPTION ))
  end

end
