require './lib/assets/app_helper.rb'
class IsrInterface < ActiveRecord::Base
  include ApplicationModel
  include ActiveModelErrorsAdd
  include Filterable

  belongs_to :l_group,    -> { readonly }, foreign_key: :l_group_id, class_name: :Group
  belongs_to :p_group,    -> { readonly }, foreign_key: :p_group_id, class_name: :Group
  belongs_to :cfr_record
  has_many   :isr_agreements, inverse_of: :isr_interface
  has_many   :active_agreements, ->{ isr_active }, class_name: :IsrAgreement, autosave: true

  after_save :update_cfr_record

  validates :l_group,
    presence: true

  validates :p_group,
    presence: true, if: Proc.new{ |me| me.p_group_id.present? }

  validates :cfr_record,
    presence: true, if: Proc.new{ |me| me.cfr_record_id.present? }

  validates :title,
    length: { maximum: MAX_LENGTH_OF_TITLE }

  validates :desc,
    length: { maximum: MAX_LENGTH_OF_DESCRIPTION }

  ISR_IF_LEVEL_LABELS = IsrInterface.human_attribute_name( :if_levels ).freeze

  validates :if_level, 
    presence: true,
    numericality: { only_integer: true },
    inclusion: { in: 0..( ISR_IF_LEVEL_LABELS.size - 1 )}

  ISR_IF_STATUS_LABELS = IsrInterface.human_attribute_name( :if_states ).freeze
  ISR_IF_STATUS_LABELM = IsrInterface.human_attribute_name( :if_states_maj ).freeze

  validates :if_status,
    presence: true,
    numericality: { only_integer: true },
    inclusion: { in: 0..( ISR_IF_STATUS_LABELS.size - 1 )}

  set_trimmed :title

  default_scope { order( :l_group_id, :p_group_id )}

  # filter scopes

  scope :ff_id, ->  ( i ){ where id: i }
  scope :ff_txt, -> ( t ){ where( 'title LIKE :param OR desc LIKE :param', param: "%#{ t }%")}
  scope :ff_grp, -> ( g ){ where( 'l_group_id = :param OR p_group_id = :param', param: g )}
  scope :ff_sts, -> ( s ){ where( if_status: s )}
  scope :ff_lvl, -> ( l ){ where( if_level: l )}

  scope :ff_ats, -> ( s ){ where( 'isr_agreements.ia_status = :param', param: s ).references( :isa_agreements )}
  scope :ff_wfs, -> ( s ){ where( 'isr_agreements.current_status = :param', param: s ).references( :isa_agreements )}

  # format interface code for display

  def code
    sprintf( "IF-%03d-%s-%s", id, l_group.try( :code ), p_group.try( :code )) unless id.nil?
  end

  def if_status_label
    ISR_IF_STATUS_LABELS[ if_status ] unless if_status.nil?
  end

  def if_level_label
    ISR_IF_LEVEL_LABELS[ if_level ] unless if_level.nil?
  end

  # an interface must not be modified once it is frozen, i.e.
  # the status is not identified (0) or defined-open (1)

  def frozen?
    self.if_status > 1
  end

  # prepare condition to restrict access to permitted groups for this user
  # this is patterned after Group.permitted_groups but considers here two
  # attributes ... to be used in queries

  def self.permitted_records( account, action )
    pg = account.permitted_groups( FEATURE_ID_ISR_INTERFACES, action )
    case pg
    when nil
      none
    when ''
      all
    else
      where( 'l_group_id IN ( :param ) OR p_group_id IN ( :param )', param: pg )
    end      
  end

  # freeze/unfreeze cfr_record
  # both require a valid l_sign_time

  def freeze_cfr_record
    return if cfr_record.nil?
    raise ArgumentError, 'freeze_cfr_record requires freeze_time' if freeze_time.nil?
    cfr_record.freeze_rec( freeze_time )
  end

  def unfreeze_cfr_record
    return if cfr_record.nil?
    raise ArgumentError, 'unfreeze_cfr_record requires freeze_time' if freeze_time.nil?
    cfr_record.unfreeze_rec( freeze_time )
  end

  # if related cfr_record was modified, save it here within the save transaction

  def update_cfr_record
    cfr_record.try( :save )
  end

  # perform all actions to mark this interface as withdrawn

  def withdraw
    self.if_status = 4
    active_agreements.each{ |ia| ia.withdraw }
  end

end
