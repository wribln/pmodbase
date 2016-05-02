class PcpItem < ActiveRecord::Base
  include ApplicationModel
  include Filterable

  belongs_to :pcp_subject,  -> { readonly }, inverse_of: :pcp_items
  belongs_to :pcp_step,     -> { readonly }, inverse_of: :pcp_items

  # pcp_step is set automatically, only reported to user

  validates :pcp_step_id, :pcp_subject_id,
    presence: true

  # seqno is computed internally, just shown to user

  validates :seqno,
    presence: true,
    numericality: { only_integer: true }

  validates :reference,
    length: { maximum: MAX_LENGTH_OF_NOTE }

  validates :description,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_DESCRIPTION }

  ITEM_STATES = PcpItem.human_attribute_name( :item_states ).freeze

  # item_status is computed internally, just shown to user

  validates :item_status,
    presence: true,
    numericality: { only_integer: true },
    inclusion: { in: 0..( ITEM_STATES.size - 1 )}

  validate :pcp_parents_must_exist

  # make sure we have a corresponding pcp_subject and pcp_step

  def pcp_parents_must_exist
    # pcp subject must exist if given
    unless pcp_subject_id.blank? then
      pu = PcpSubject.find_by_id( pcp_subject_id )
      errors.add( :pcp_subject_id, I18n.t( 'pcp_items.msg.no_pcp_subject' )) if pu.nil?
    end
    # pcp step must exist if given
    unless pcp_step_id.blank? then
      pt = PcpStep.find_by_id( pcp_step_id )
      errors.add( :pcp_step_id, I18n.t( 'pcp_items.msg.no_pcp_step' )) if pt.nil?
    end
    # last check - only if previous checks were OK
    errors.add( :base, I18n.t( 'pcp_items.msg.pcp_subject_step' )) \
      if errors.empty? && ( pt.pcp_subject.id != pcp_subject_id )
  end

  # return the sequence number to use for the next item

  def set_next_seqno
    a = self.pcp_subject.pcp_items
    m = a.maximum( :seqno ) || 0
    n = a.count
    self.seqno = ( n > m ? n : m ) + 1
  end    

  # label for status

  def item_status_label
    ITEM_STATES[ item_status ]
  end

end
