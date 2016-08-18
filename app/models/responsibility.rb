require './lib/assets/app_helper.rb'
class Responsibility < ActiveRecord::Base
  include ApplicationModel
  include ActiveModelErrorsAdd
  include Filterable

  belongs_to :person, inverse_of: :responsibilities
  belongs_to :group, inverse_of: :responsibilities

  validates :seqno,
    presence: true,
    numericality: { only_integer: true }

  validates :description,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_DESCRIPTION }

  # person_id can be 0 ("N.N."), or must exist

  validates :person,
    presence: true, if: Proc.new{ |me| me.person_id.present? }

  # The module only checks here if the given group exists but it should
  # also be an active participant: This is somewhat controlled by the
  # list of possible groups in the controller, but may have to be enforced
  # later if needed on the module level. 

  validates :group,
    presence: true

  scope :ff_group,  -> ( group  ){ where group_id: group }
  scope :ff_resp,   -> ( resp   ){ where( 'description like ?', "%#{ resp }%" )}
  scope :ff_email,  -> ( email  ){ where( 'people.email like ?', "%#{ email }%" ).references( :people )}
  scope :ff_name,   -> ( name   ){ where( '( people.formal_name LIKE ? ) OR ( people.informal_name LIKE ? )', "%#{ name }%", "%#{ name }%" ).references( :people )}
  scope :ff_dept,   -> ( dept   ){ where( 'contact_infos.department like ?', "#{ dept }%" ).references( :contact_infos )}

  set_trimmed :description

end
