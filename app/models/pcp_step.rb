# this model contains all PCP Step related information,
# especially all information relevant for a specific release to
# the other party (i.e. copies of some PCP Subject data which
# is needed to recreate any release report)

class PcpStep < ActiveRecord::Base

  belongs_to :pcp_subject, -> { readonly }, inverse_of: :pcp_steps

  validates :pcp_subject_id,
    presence: true

  validates :step_no,
    presence: true,
    uniqueness: { scope: :pcp_subject_id, message: I18n.t( 'pcp_steps.msg.dup_step' )},
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  STEP_LABELS = PcpStep.human_attribute_name( :step_labels ).freeze
  STEP_STATES = PcpStep.human_attribute_name( :step_states ).freeze

  validates :subject_version, :report_version,
    length: { maximum: MAX_LENGTH_OF_DOC_VERSION }

  validates :note,
    length: { maximum: MAX_LENGTH_OF_NOTE }

  validates :subject_date, :due_date,
    date_field: { presence: false }

  SUBJECT_STATES = PcpStep.human_attribute_name( :subject_states ).freeze

  validates :subject_status,
    numericality: { only_integer: true },
    inclusion: { in: 0..( SUBJECT_STATES.size - 1 )}

  validates :subject_title,
    length: { maximum: MAX_LENGTH_OF_DESCRIPTION }

  validates :project_doc_id,
    length: { maximum: ProjectDocLog::MAX_LENGTH_OF_DOC_ID }

  ASSESSMENT_CODES = PcpStep.human_attribute_name(  :ass_codes  ).freeze
  ASSESSMENT_LABELS = PcpStep.human_attribute_name( :ass_labels ).freeze

  validates :prev_assmt,
    numericality: { only_integer: true },
    inclusion: { in: 0..( ASSESSMENT_CODES.size - 1 )}

  validates :prev_assmt,
    presence: false,
    numericality: { only_integer: true },
    inclusion: { in: 0..( ASSESSMENT_CODES.size - 1 )}

  validates :released_by,
    length: { maximum: MAX_LENGTH_OF_ACCOUNT_NAME + MAX_LENGTH_OF_PERSON_NAMES }

  validate :pcp_subject_must_exist
  validate :no_assessment_in_step_0

  # default scope for access through PCP Subjects

  scope :most_recent, -> { order( step_no: :desc )}

  # make sure the given pcp_subject really exists - just to be on the safe side...

  def pcp_subject_must_exist
    unless pcp_subject_id.nil? then
      errors.add( :pcp_subject_id, I18n.t( 'pcp_steps.msg.bad_subject' )) \
        unless PcpSubject.exists?( pcp_subject_id )
    end
  end

  # there should be no assessment in step 0!

  def no_assessment_in_step_0
    if step_no == 0
      errors.add( :prev_assmt, I18n.t( 'pcp_steps.msg.bad_assessment' )) \
        unless prev_assmt == 0
      errors.add( :new_assmt, I18n.t( 'pcp_steps.msg.bad_assessment' )) \
        unless new_assmt.nil?
    end
  end

  # determine action for release
  # (0) release ok
  # (1) release to final, close status
  # (2) not possible to release due to errors

  def release_type

    # general test

    errors.add( :report_version, I18n.t( 'pcp_steps.msg.no_reqd_input' )) \
      if report_version.blank?

    # acting group specific tests

    if in_presenting_group? then
      errors.add( :base, I18n.t( 'pcp_steps.msg.missng_subject' )) \
        if pcp_subject.title.blank? && pcp_subject.project_doc_id.blank? 
      errors.add( :base, I18n.t( 'pcp_steps.msg.clsd_subj_no_r' )) \
        if status_closed?
      errors.add( :base, I18n.t( 'pcp_steps.msg.no_subject_status' )) \
        if subject_date.blank? && subject_version.blank?
    else # in commenting group
      errors.add( :new_assmt, I18n.t( 'pcp_steps.msg.no_reqd_input' )) \
        if new_assmt.nil?
    end

    # finally

    if errors.empty? then
      new_subject_status == 2 ? 1 : 0
    else
      2
    end
  end

  # the following use hard-coded states:
  #     0 - new
  #     1 - open
  #     2 - closed

  # indicate to caller if this step refers to a closed subject:

  def status_closed?
    subject_status == 2
  end

  # what is the current assessment of the subject?
  # the assumed requirement is that prev_assmt is
  # always set (not nil) and the new_assmt may
  # be nil until set; if set, then the new assessment
  # is certainly new_assmt:

  def current_assmt
    new_assmt || prev_assmt
  end

  # new for step_no 0; closed on 'A' or 'D', open else

  def new_subject_status
    if step_no == 0 then
      0 # new
    else
      a = current_assmt
      if( a == 1 or a == 4 )then
        2 # closed
      else
        1 # open
      end
    end
  end

  # provide codes and label for the assessment

  def self.assessment_code( a )
    ASSESSMENT_CODES[ a || 0 ]
  end

  def self.assessment_label( a )
    ASSESSMENT_LABELS[ a || 0 ]
  end

  # provide label for subject status

  def subject_status_label
    SUBJECT_STATES[ subject_status ]
  end

  # provide a label for the curren step

  def step_label
    if step_no < STEP_LABELS.size then
      STEP_LABELS[ step_no ]
    else
      I18n.t( 'activerecord.attributes.pcp_step.step_label', ss: STEP_STATES[ acting_group_index ], no: (( step_no + 1 ) >> 1 ))
    end
  end

  # make sure no leading/trailing blanks are stored

  def subject_version=( text )
    write_attribute( :subject_version, AppHelper.clean_up( text, MAX_LENGTH_OF_DOC_VERSION ))
  end

  def report_version=( text )
    write_attribute( :report_version, AppHelper.clean_up( text, MAX_LENGTH_OF_DOC_VERSION ))
  end

  # Regarding PCP subjects, I need to distinguish between the 'acting_group' -
  # this can be the presenting or the commenting group, and the 'viewing_group'
  # which determins what the user can view. The viewing_group is determined in
  # the (PCP subjects) controller as this is derived from the current user.

  # The acting_group is either
  #  0 - presenting group, or
  #  1 - commenting group
  # which can easily be derived from the step_no (the presenting group starts
  # with the initial release step 0, the reviewing group is next with step 1).
  # However, once the PCP subject is closed by the reviewing group, there is no
  # new step but the acting_group is the presenting group.

  def acting_group_index
    if status_closed? then
      0
    else
      step_no & 1
    end
  end

  public

  def in_presenting_group?
    acting_group_index == 0
  end

  def in_commenting_group?
    acting_group_index == 1
  end

  # create a new step based on the current one

  def create_release_from( prev_step, current_user )
    prev_step.set_release_data( current_user )
    self.step_no = prev_step.step_no + 1
    self.subject_status = prev_step.subject_status
    self.report_version = nil
    if in_presenting_group? then
      self.prev_assmt = prev_step.new_assmt || prev_step.prev_assmt
      self.new_assmt = nil
      self.subject_version = nil
    else
      self.subject_version = prev_step.subject_version
      self.prev_assmt = prev_step.prev_assmt
      self.new_assmt = prev_step.new_assmt
    end
  end

  # update release information in 'previous' step

  def set_release_data( current_user )
    self.subject_status = new_subject_status
    self.released_by = "#{ current_user.user_name } (#{ current_user.name_with_id })"
    self.released_at = DateTime.now
    self.subject_title = pcp_subject.title
    self.project_doc_id = pcp_subject.project_doc_id
  end    

end
