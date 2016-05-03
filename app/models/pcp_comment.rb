class PcpComment < ActiveRecord::Base
  belongs_to :pcp_item, -> { readonly }, inverse_of: :pcp_comments
  belongs_to :pcp_step, -> { readonly }, inverse_of: :pcp_comments

  validates :pcp_step_id, :pcp_item_id,
    presence: true

  validates :assessment,
    presence: true,
    numericality: { only_integer: true },
    inclusion: { in: 0..( PcpItem::ASSESSMENT_LABELS.size - 1 )}

  validate :pcp_parents_must_exist

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

end
