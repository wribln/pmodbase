require './lib/assets/app_helper.rb'
class CsrStatusRecord < ActiveRecord::Base
  include ApplicationModel
  include Filterable
  include GroupCheck

  belongs_to :sender_group,   -> { readonly }, foreign_key: 'sender_group_id',        class_name: 'Group'
  belongs_to :receiver_group, -> { readonly }, foreign_key: 'receiver_group_id',      class_name: 'Group'
  belongs_to :sent_item,      -> { readonly }, foreign_key: 'reply_status_record_id', class_name: 'CsrStatusRecord'

  before_save :set_defaults

  validates :actual_reply_date,
    date_field: { presence: false }

  CSR_CLASS_LABELS = CsrStatusRecord.human_attribute_name( :classifications ).freeze

  validates :classification,
    allow_blank: true,
    numericality: { only_integer: true },
    inclusion: { in: 0..( CSR_CLASS_LABELS.size - 1 )}

  validates :correspondence_date,
    date_field: { presence: true }

  # 0 - incoming
  # 1 - outgoing

  CSR_CORRESP_TYPE_LABELS = CsrStatusRecord.human_attribute_name( :correspondence_types ).freeze

  validates :correspondence_type,
    allow_blank: false,
    numericality: { only_integer: true },
    inclusion: { in: 0..( CSR_CORRESP_TYPE_LABELS.size - 1 )}

  validates :notes,
    length: { maximum: MAX_LENGTH_OF_NOTE }

  validates :plan_reply_date,
    date_field: { presence: false }

  validates :project_doc_id,
    length: { maximum: MAX_LENGTH_OF_DOC_ID }

  validate { given_group_exists( :receiver_group_id )}

  validates :sender_doc_id,
    length: { maximum: MAX_LENGTH_OF_DOC_ID }

  validate { given_group_exists( :sender_group_id   )}

  validates :sender_reference,
    length: { maximum: MAX_LENGTH_OF_DOC_ID }

  validate :given_sent_item_valid

  CSR_STATUS_LABELS = CsrStatusRecord.human_attribute_name( :states ).freeze

  validates :status,
    allow_blank: false,
    numericality: { only_integer: true },
    inclusion: { in: 0..( CSR_STATUS_LABELS.size - 1 )}

  validates :subject,
    length: { maximum: MAX_LENGTH_OF_TITLE }

  CSR_TRANSM_TYPE_LABELS = CsrStatusRecord.human_attribute_name( :transmission_types ).freeze

  validates :transmission_type,
    allow_blank: true,
    numericality: { only_integer: true },
    inclusion: { in: 0..( CSR_TRANSM_TYPE_LABELS.size - 1)}

  default_scope{ order correspondence_date: :desc }
  scope :active, -> { where status: [ 0,1 ]}

  # filter scopes

  scope :ff_id,     -> ( id     ){ where id: id }
  scope :ff_type,   -> ( type   ){ where correspondence_type: type }
  scope :ff_group,  -> ( group  ){ where( 'sender_group_id = ? OR receiver_group_id = ?', group, group ) }
  scope :ff_class,  -> ( clftn  ){ where classification: clftn }
  scope :ff_status, -> ( status ){ where status: status }
  scope :ff_subj,   -> ( subj   ){ where( 'subject LIKE ?', "%#{ subj }%" )}
  scope :ff_note,   -> ( note   ){ where( 'notes LIKE ?',   "%#{ note }%" )}

  # set defaults

  def set_defaults
    set_default!( :status, 0 )
    set_default!( :correspondence_date, Date.today )
  end

  # helper for easier reading of code...

  def incoming?
    correspondence_type == 0
  end

  def outgoing?
    correspondence_type == 1
  end

  # retrieve group_code to display in index/show

  def sender_group_code
    ( sender_group.try :code ) || some_id( sender_group_id )
  end  

  def receiver_group_code
    ( receiver_group.try :code ) || some_id( receiver_group_id )
  end

  def sender_receiver_group_code
    incoming? ? sender_group_code : receiver_group_code
  end

  def correspondence_type_label
    CSR_CORRESP_TYPE_LABELS[ correspondence_type ] unless correspondence_type.nil?
  end

  def transmission_type_label
    CSR_TRANSM_TYPE_LABELS[ transmission_type ] unless transmission_type.nil?
  end

  def classification_label
    CSR_CLASS_LABELS[ classification ] unless classification.nil?
  end

  def status_label
    CSR_STATUS_LABELS[ status ] unless status.nil?
  end

  protected

  # make sure the given CSR item really exists,
  # and it points to another correspondence record of opposite type

  def given_sent_item_valid
    if reply_status_record_id.present? then
      reply = CsrStatusRecord.where( id: reply_status_record_id ).first
      if reply.nil? then
        errors.add( :reply_status_record_id, I18n.t( 'csr_status_records.msg.bad_csr_item' ))
        return
      end
      unless reply.id != self.id then
        errors.add( :reply_status_record_id, I18n.t( 'csr_status_records.msg.bad_csr_id' ))
        return
      end
      unless reply.correspondence_type != self.correspondence_type
        errors.add( :reply_status_record_id, I18n.t( 'csr_status_records.msg.bad_types' ) + correspondence_type_label )
        return
      end
    end
  end

end
