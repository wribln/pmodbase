class PcpItem < ActiveRecord::Base
  include ApplicationModel
  include Filterable

  belongs_to :pcp_subject,  -> { readonly }, inverse_of: :pcp_items
  belongs_to :pcp_step,     -> { readonly }, inverse_of: :pcp_items
  has_many   :pcp_comments,    dependent: :destroy, inverse_of: :pcp_item

  before_save :update_item_assessment

  # pcp_step is set automatically, only reported to user

  validates :pcp_step_id, :pcp_subject_id,
    presence: true

  # seqno is computed internally, just shown to user

  validates :seqno,
    presence: true,
    numericality: { only_integer: true }

  # author is set to current user automatically but may be changed: 

  validates :author,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_ACCOUNT_NAME + MAX_LENGTH_OF_PERSON_NAMES }

  validates :reference,
    length: { maximum: MAX_LENGTH_OF_NOTE }

  validates :description,
    presence: true

  ASSESSMENT_LABELS = PcpItem.human_attribute_name( :assessments ).freeze

  validates :item_assmnt,
    allow_blank: true,
    numericality: { only_integer: true },
    inclusion: { in: 0..( ASSESSMENT_LABELS.size - 1 )}

  validates :assessment,
    presence: true,
    numericality: { only_integer: true },
    inclusion: { in: 0..( ASSESSMENT_LABELS.size - 1 )}

  validate :pcp_parents_must_exist

  # released items of given subject for public viewing

  scope :released, ->( s ){ where( pcp_subject: s ).joins( :pcp_step ).merge( PcpStep.released )}
  scope :released_until, ->( s, n ){ where( pcp_subject: s ).joins( :pcp_step ).merge( PcpStep.released_until( n ))}

  # test whether item is released (needed for permissions):
  # this is recognized by the release date not being set

  def released?
    pcp_step.released?
  end 

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

  # collect from comment records the current step's assessment

  def update_item_assessment
    lc = self.pcp_comments.last
    self.item_assmnt = lc.nil? ? self.assessment : lc.assessment
  end

  # return true if the given assessment leads to a closed status
  # MUST CHECK this if assessment states are modified

  def closed?
    self.class.closed?( assessment )
  end

  def self.closed?( a )
    a == 2
  end

  # return the sequence number to use for the next item

  def set_next_seqno
    a = self.pcp_subject.pcp_items
    m = a.maximum( :seqno ) || 0
    n = a.count
    self.seqno = ( n > m ? n : m ) + 1
  end 

  # try to get the next item in sequence: I am doing this on the id as the seqno is not
  # fully reliable; id and seqno are a positive linear function, they are in the same
  # sequence, i.e. pcp_item_1.id > pcp_item_2.id => pcp_item_1.seqno > pcp_item_2.seqno

  def find_next
    PcpItem.where( pcp_subject_id: pcp_subject_id ).where( 'id > ?', id ).order( id: :asc ).first
  end

  def self.assessment_label( i )
    ASSESSMENT_LABELS[ i ] unless i.nil?
  end

end
