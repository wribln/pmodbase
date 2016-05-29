class PcpItem < ActiveRecord::Base
  include ApplicationModel
  include Filterable

  belongs_to :pcp_subject,  -> { readonly }, inverse_of: :pcp_items
  belongs_to :pcp_step,     -> { readonly }, inverse_of: :pcp_items
  has_many   :pcp_comments,    dependent: :destroy, inverse_of: :pcp_item

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

  # pub_assmt is the current, public assessment of this PCP Item
  # new_assmt is the current assessment by the acting party for the
  # next release where this assessment would become the next public
  # assessment.
  # pub_assmt must be set to new_assmt during release of step
  # assessment is the initial assessment of the PCP Item.

  # NOTE: if assessments are modified, closed? methods may need to
  # be modified as well!

  validates :pub_assmt, :new_assmt,
    allow_blank: true,
    numericality: { only_integer: true },
    inclusion: { in: 0..( ASSESSMENT_LABELS.size - 1 )}

  validates :assessment,
    presence: true,
    numericality: { only_integer: true },
    inclusion: { in: 0..( ASSESSMENT_LABELS.size - 1 )}

  validate :pcp_parents_must_exist

  # released items of given subject for public viewing

  default_scope{ order( id: :asc )}
  scope :released, ->( s ){ where( pcp_subject: s ).joins( :pcp_step ).merge( PcpStep.released )}
  scope :released_until, ->( s, n ){ where( pcp_subject: s ).joins( :pcp_step ).merge( PcpStep.released_until( n ))}

  # test whether item is released (needed for permissions):
  # this is recognized by the release date not being set;
  # another, equivalent condition should be pub_assmt not being nil

  def released?
    pub_assmt || pcp_step.released?
  end

  # need to update :new_assmt if :assessment changes while :pub_assmt is nil

  def assessment=( a )
    write_attribute( :assessment, a )
    self.new_assmt = a if pub_assmt.nil? && pcp_comments.is_public.empty?
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

  # during a release, update pub_assmt to reflect the assessment of the
  # the last public comment

  def release_item
    self.pub_assmt = new_assmt
  end

  # use update_new_assmt when changing the :is_public attribute
  # of a PCP Comments belonging to this item; or when removing a
  # PCP Comment.
  # NOTE: in the current process, I assume that an update can only be
  # performed on the last, current PCP Comment. Hence, if this record
  # is published, its assessment will become the next public assessment
  # for this item.
  # NOTE: in order for this method to work also when a PCP Comment is
  # destroyed, I need to check for a valid last comment

  def update_new_assmt( c )
    if c && c.is_public then
      new_assmt_to_set = c.assessment
    else
      # need to find assessment to use
      if c.nil? then # comment is destroyed, look for last to use
        ps = pcp_subject.current_step
        pc = pcp_comments.for_step( ps )
        if pc.count == 0 then # no comments exists for this step
          new_assmt_to_set = pub_assmt # use last released assessment
        else # use last comment unless a public comment exists
          new_assmt_to_set = pc.last.assessment
          pc.each do |p|
            new_assmt_to_set = p.assessment if p.is_public
          end
        end
      else
        pc = pcp_comments.is_public.for_step( c.pcp_step )
        if pc.count == 0 then # no further public comments for current step
          if c.pcp_step == pcp_step then # we are at the PCP Item here
            new_assmt_to_set = assessment # use PCP Item's assessment
          else 
            new_assmt_to_set = c.assessment # uses current (assumed: last) comment
          end
        else # use last public comment
          new_assmt_to_set = pc.last.assessment # use last public comment
        end
      end
    end
    update_attribute( :new_assmt, new_assmt_to_set )
  end

  # the following method is only to validate the assessment setting
  # (to be used for testing or validation of the objects' integrity)
  # it returns 0 if all is ok, else an indicator on what went wrong

  def valid_assessment?
    ps = pcp_subject.current_steps
    if ps[ 1 ].nil? then # current step is the first, initial step
      pc = pcp_comments.is_public.for_step( pcp_step )
      if pc.count == 0 then # no public comments for first step
        ( ps[ 0 ] == pcp_step && pub_assmt.nil? && new_assmt == assessment ) ? 0 : 1
      else # public comment overrides assessment of PCP Item
        ( ps[ 0 ] == pcp_step && pub_assmt.nil? && new_assmt == pc.last.assessment ) ? 0 : 2
      end
    else # determine current assessment
      pc = pcp_comments.for_step( ps[ 0 ])
      if pc.count > 0 then
        pla = pc.last.assessment # default: last comment, public or not
        pc.each do | c |
          pla = c.assessment if c.is_public
        end
      else
        pla = nil # have no current assessment
      end
      # determine last released assessment
      pc = pcp_comments.is_public.for_step( ps[ 1 ])
      if pc.count > 0 then
        plp = pc.last.assessment # default: last public comment
      else # no public comments, this can only mean, that we are at PCP Step 0:
        plp = self.assessment
      end
      if pla.nil? then
        ( pub_assmt == plp && new_assmt == plp ) ? 0 : 3
      else
        ( pub_assmt == plp && new_assmt == pla ) ? 0 : 4
      end
    end
  end

  # return true if the given assessment leads to a closed status

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
    PcpItem.where( pcp_subject_id: pcp_subject_id ).where( 'id > ?', id ).first
  end

  def self.assessment_label( i )
    ASSESSMENT_LABELS[ i ] unless i.nil?
  end

end
