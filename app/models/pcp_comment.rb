class PcpComment < ActiveRecord::Base
  includes PcpAssessmentModel
  
  belongs_to :pcp_item,                  inverse_of: :pcp_comments
  belongs_to :pcp_step, -> { readonly }, inverse_of: :pcp_comments

  attr_accessor :update_item_flag

  after_save :update_item, :if => :update_item_flag

  validates :pcp_step_id, :pcp_item_id,
    presence: true

  validates :description,
    presence: true

  # author is set to current user automatically but may be changed: 

  validates :author,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_ACCOUNT_NAME + MAX_LENGTH_OF_PERSON_NAMES }

  validate :pcp_parents_must_exist
  validate :public_requirements

  default_scope{ order( created_at: :asc )}
  scope :for_step, ->( s ){ where( pcp_step: s )}
  scope :is_public, ->{ where( is_public: true )}

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
    if is_public then
      errors.add( :description, I18n.t( 'pcp_comments.msg.descr_mssng' )) \
        if description.blank? && !PcpItem.closed?( assessment )
    end
  end

  # determine whether this comment is public and step was released

  def published?
    is_public && pcp_step.released?
  end

  # use make_public to set the is_public flag alone
  # Note: this triggers also the update_item callback -
  # no need to explicitly do this here

  def make_public
    update_attribute( :is_public, true )
  end

  # if the :is_public or :assessment attribute changes, we need to
  # report it up to the PCP Item so the assessment for the current step
  # is updated accordingly:
  #
  # this is implemented by setting a flag which triggers a 
  # before_save callback later

  def is_public=( f )
    self.update_item_flag = ( is_public != f )
    write_attribute( :is_public, f ) if self.update_item_flag
  end

  def assessment=( a )
    self.update_item_flag = ( assessment != a )
    write_attribute( :assessment, a ) if self.update_item_flag
  end

  # callback to update related PCP Item

  def update_item
    pcp_item.update_new_assmt( self )
  end

end
