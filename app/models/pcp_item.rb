# Notes on PCP Items
#
# - PCP Items can only be created by the Commenting Group
# - Assessments can only be made by the Commenting Group
#   and they cannot be changed by the Presenting Group
# - any PCP Item has 0 or more PCP Comments
# - the related PCP Step must always be odd as all PCP Items
#   are created by the Commenting Group


class PcpItem < ActiveRecord::Base
  include ApplicationModel
  include PcpAssessmentModel
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

  validate :pcp_relationship

  # released items of given subject for public viewing

  default_scope{ order( id: :asc )}
#  scope :released, ->( s ){ where( pcp_subject: s ).joins( :pcp_step ).merge( PcpStep.released )}
  scope :released, ->{ joins( :pcp_step ).merge( PcpStep.released )}
  scope :released_until, ->( n ){ joins( :pcp_step ).merge( PcpStep.released_until( n ))}

  # test whether item is released (needed for permissions)

  def released?
    pub_assmt || pcp_step.released?
  end

  # when is an item closed?

  def closed?
    self.class.closed?( pub_assmt )
  end
  
  # need to update :new_assmt if :assessment changes while :pub_assmt is nil

  def assessment=( a )
    write_attribute( :assessment, a )
    self.new_assmt = a if pub_assmt.nil? && pcp_comments.is_public.empty?
  end 
  
  # make sure we have a corresponding PCP Subject and a correct PCP Step, i.e.
  # both must exist, and PCP Step must be by Commenting Group (PCP Steps can
  # only be created by Commenting Group)

  def pcp_relationship
    # pcp subject must exist if given
    unless pcp_subject_id.blank? then
      pu = PcpSubject.find_by_id( pcp_subject_id )
      errors.add( :pcp_subject_id, I18n.t( 'pcp_items.msg.no_pcp_subject' )) if pu.nil?
    end
    # pcp step must exist if given
    pt = nil # scope
    unless pcp_step_id.blank? then
      pt = PcpStep.find_by_id( pcp_step_id )
      if pt.nil? then
        errors.add( :pcp_step_id, I18n.t( 'pcp_items.msg.no_pcp_step' ))
      elsif pt.in_presenting_group?
        errors.add( :pcp_step_id, I18n.t( 'pcp_items.msg.wrong_group' ))
      end
    end
    # last check - only if all previous validations were OK
    errors.add( :base, I18n.t( 'pcp_items.msg.pcp_subject_step' )) \
      if errors.empty? && ( pt.pcp_subject.id != pcp_subject_id )
  end

  # during a release, update pub_assmt to reflect the assessment of the
  # the last public comment

  def release_item
    update_attribute( :pub_assmt, new_assmt )
  end

  # use update_new_assmt when changing the :is_public attribute
  # of a PCP Comments belonging to this item; or when removing a
  # PCP Comment; or when creating a new PCP Comment.
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
          elsif c.pcp_step.in_commenting_group?
            new_assmt_to_set = c.assessment # uses current (assumed: last) comment
          elsif new_assmt == c.assessment
            return # ignore update request - all is OK
          else
            # c.pcp_step.in_presenting_group? - business logic error!
            raise I18n.t( 'pcp_comments.msg.nop_to_assess')
          end
        else # use last public comment
          new_assmt_to_set = pc.last.assessment # use last public comment
        end
      end
    end
    update_attribute( :new_assmt, new_assmt_to_set ) if new_assmt != new_assmt_to_set
  end

  # helper method to check if assessment has changed

  def assessment_changed?( a = nil )
    ( pub_assmt != new_assmt ) || ( new_assmt != ( a || assessment ))
  end

  # the following method is only to validate the integrity of the current item,
  # specifically its assessment setting; the method returns 0 if all is ok,
  # else an indicator on what went wrong; use it as additional validation AFTER
  # self.valid?

  def valid_item?
    # PCP Items can only be created by Commenting Group
    return 1 if pcp_step.in_presenting_group?

    # scenario without comments; note that I can safely assume that there are at
    # least two steps ... because it is not allowed to add PCP Items to the first
    # PCP Step (0), hence the current step is at least PCP Step (1).
    ps = pcp_subject.current_steps
    if pcp_comments.count == 0 then
      if pcp_step == ps[ 0 ] # newly created?
        return ( pub_assmt.nil? && new_assmt == assessment ) ? 0 : 2
      elsif pcp_step == ps[ 1 ] # new item released
        return ( pub_assmt == new_assmt && new_assmt == assessment ) ? 0 : 3
      else
        # inconsistent: there should be comments in the previous step
        return 4
      end
    end
    # we have comments here ( pcp_comments.count > 0 )
    
    # if PCP Item was newly created for step, last public comment -
    # if existing - determines current assessment, else assessment
    if pcp_step == ps[ 0 ]
      return 5 unless pub_assmt.nil?
      na = assessment
      pcp_comments.each do | c |
        return 6 unless c.pcp_step == pcp_step
        na = c.assessment if c.is_public
      end
      return ( new_assmt == na ) ? 0 : 7
    end

    # PCP Item was created for earlier step, determine current assessment
    # from current comments: default is last, most recent comment, look
    # for any public comments which then override new_assmt
    pc = pcp_comments.for_step( ps[ 0 ])
    if pc.count == 0 
      # no comments for current step (yet - or if closed)
      return 8 unless ( pub_assmt == new_assmt )
    elsif ps[ 0 ].in_commenting_group?
      na = pc.last.assessment
      pc.each do | c |
        na = c.assessment if c.is_public
      end
      return 9 unless ( new_assmt ==  na )
    else
      # no assessment changes allowed by presenting group
      pc.each do | c |
        return 10 if assessment_changed?( c.assessment )
      end
    end

    # now check if pub_assmt is correctly computed from previous step:
    # determine last released assessment, if any

    if ps[ 1 ].in_presenting_group?
      # there should be no changes at all
      pc = pcp_comments.for_step( ps[ 1 ])
      pc.each do | c |
        return 11 unless ( pub_assmt == c.assessment )
        # note: new_assmt could be different now due to new comments
        # in current step ...
      end
    else # in_commenting_group?
      pc = pcp_comments.is_public.for_step( ps[ 1 ])
      if pc.count > 0
        return 12 unless ( pub_assmt == pc.last.assessment )
      else # no public comments, assessment comes from item
        return 13 unless ( pub_assmt == new_assmt && new_assmt == assessment )
      end
    end

    return 0
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

end
