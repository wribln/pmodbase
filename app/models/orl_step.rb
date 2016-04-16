class OrlStep < ActiveRecord::Base

  belongs_to :orl_subject, -> { readonly }, inverse_of: :orl_steps

  after_validation :determine_subject_status

  validates :orl_subject_id,
    presence: true

  validates :step_no,
    presence: true,
    uniqueness: { scope: :orl_subject_id, message: I18n.t( 'orl_steps.msg.dup_step' )},
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  STEP_LABELS = OrlStep.human_attribute_name( :step_labels ).freeze
  STEP_STATES = OrlStep.human_attribute_name( :step_states ).freeze

  validates :subject_version,
    length: { maximum: MAX_LENGTH_OF_DOC_VERSION }

  validates :note,
    length: { maximum: MAX_LENGTH_OF_NOTE }

  validates :subject_date, :due_date,
    date_field: { presence: false }

  SUBJECT_STATES = OrlStep.human_attribute_name( :subject_states ).freeze

  validates :subject_status,
    numericality: { only_integer: true },
    inclusion: { in: 0..( SUBJECT_STATES.size - 1 )}

  ASSESSMENT_CODES = OrlStep.human_attribute_name(  :ass_codes  ).freeze
  ASSESSMENT_LABELS = OrlStep.human_attribute_name( :ass_labels ).freeze

  validates :assessment,
    numericality: { only_integer: true },
    inclusion: { in: 0..( ASSESSMENT_CODES.size - 1 )}

  validate :orl_subject_must_exist

  # default scope for access through ORL Subjects

  scope :most_recent, -> { order( step_no: :desc )}

  # make sure the given orl_subject really exists - just for safety

  def orl_subject_must_exist
    unless orl_subject_id.nil? then
      errors.add( :orl_subject_id, I18n.t( 'orl_steps.msg.bad_subject' )) \
        unless OrlSubject.exists?( orl_subject_id )
    end
  end

  # indicate to caller if this step refers to a closed subject:

  def status_closed?
    subject_status == SUBJECT_STATES.size - 1
  end

  # new for step_no 0 and 1; closed on 'A' or 'D'

  def determine_subject_status
    subject_status = 1 if step_no > 1
    subject_status = 2 if assessment == 0 or assessment == 3
  end

  # provide codes and label for the assessment

  def assessment_code
    ASSESSMENT_CODES[ assessment ]
  end

  def assessment_label
    ASSESSMENT_LABELS[ assessment ]
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
       ( step_no >> 1 ).ordinalize + ' ' + STEP_STATES[ ballpark ]
    end
  end

  # return 0 if current owner is originator/responding group,
  #        1 if observing/reviewing group

  def ballpark
    step_no & 1
  end

  def in_responding_group?
    ballpark == 0
  end

  def in_observing_group?
    ballpark == 1
  end

end
