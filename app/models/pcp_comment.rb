class PcpComment < ActiveRecord::Base
  belongs_to :pcp_item, -> { readonly }, inverse_of: :pcp_comments
  belongs_to :pcp_step, -> { readonly }, inverse_of: :pcp_comments

  validates :pcp_step_id, :pcp_item_id,
    presence: true

  validates :description,
    presence: true

  validates :assessment,
    presence: true,
    numericality: { only_integer: true },
    inclusion: { in: 0..( PcpItem::ASSESSMENT_LABELS.size - 1 )}

  # author is set to current user automatically but may be changed: 

  validates :author,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_ACCOUNT_NAME + MAX_LENGTH_OF_PERSON_NAMES }

  validate :pcp_parents_must_exist
  validate :public_requirements

  # make sure we have a corresponding pcp_item and pcp_step

  def pcp_parents_must_exist
    # pcp step must exist if given
    unless pcp_step_id.blank? then
      ps = PcpStep.find_by_id( pcp_step_id )
      errors.add( :pcp_step_id, I18n.t( 'pcp_comments.msg.no_pcp_step' )) if ps.nil?
    end
    # pcp item must exist if given
    unless pcp_item_id.blank? then
      pi = PcpItem.find_by_id( pcp_item_id )
      errors.add( :pcp_item_id, I18n.t( 'pcp_comments.msg.no_pcp_item' )) if pi.nil?
    end
    # last check - only if previous checks were ok
    errors.add( :base, I18n.t( 'pcp_comments.msg.pcp_subject_ref' )) \
      if errors.empty? && ( ps.pcp_subject_id != pi.pcp_subject_id )
  end

  # make sure public can only be set when
  # (1) a description is there - unless the assessment is terminal

  def public_requirements
    if self.is_public then
      errors.add( :description, I18n.t( 'pcp_comments.msg.descr_mssng' )) \
        if description.blank? && !PcpItem.closed?( assessment )
    end
  end

  # determine whether this comment is public and step was released

  def published?
    is_public && pcp_step.released?
  end

end
