class PcpComment < ActiveRecord::Base
  include PcpAssessmentModel
  
  belongs_to :pcp_item,                  inverse_of: :pcp_comments
  belongs_to :pcp_step, -> { readonly }, inverse_of: :pcp_comments

  attr_accessor :update_item_flag

  after_save    :update_item, :if => :update_item_flag # only needed if flag set
  after_create  :update_item # always!

  validates :pcp_step_id, :pcp_item_id,
    presence: true

  validates :description,
    presence: true

  # author is set to current user automatically but may be changed: 

  validates :author,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_ACCOUNT_NAME + MAX_LENGTH_OF_PERSON_NAMES }

  validate :pcp_parents
  validate :public_requirements

  default_scope{ order( created_at: :asc )}
  scope :for_step, ->( s ){ where( pcp_step: s )}
  scope :is_public, ->{ where( is_public: true )}

  # make sure we have a corresponding PCP Item and PCP Step, and
  # make other checks regarding integrity

  def pcp_parents
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
    # stop checking here if there were already errors
    return unless errors.empty?
    # Presenting Group must not change assessment
    if pcp_step.in_presenting_group?
      if pcp_item.assessment_changed?( assessment )
        errors.add( :assessment, I18n.t( 'pcp_comments.msg.nop_to_assess' ))
      elsif closed?
        errors.add( :assessment, I18n.t( 'pcp_commens.msg.nop_to_close'))
      end
    end
    # last sanity check
    if ( ps.pcp_subject_id != pi.pcp_subject_id )
      errors.add( :base, I18n.t( 'pcp_comments.msg.pcp_subject_ref' ))
    end
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

  # when is a comment closed?

  def closed?
    self.class.closed?( assessment )
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
