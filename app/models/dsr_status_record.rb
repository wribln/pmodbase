require './lib/assets/app_helper.rb'
class DsrStatusRecord < ActiveRecord::Base
  include ApplicationModel
  include Filterable
  include GroupCheck
  include ProgrammeActivityCheck

  belongs_to :dsr_progress_rate,  -> { readonly }, foreign_key: :document_status,   primary_key: :document_status, class_name: :DsrProgressRate
  belongs_to :dsr_progress_rate_b,-> { readonly }, foreign_key: :document_status_b, primary_key: :document_status, class_name: :DsrProgressRate  
  belongs_to :sender_group,       -> { readonly }, foreign_key: :sender_group_id,   class_name: :Group
  belongs_to :sender_group_b,     -> { readonly }, foreign_key: :sender_group_b_id, class_name: :Group
  belongs_to :receiver_group,     -> { readonly }, foreign_key: :receiver_group_id, class_name: :Group
  belongs_to :submission_group,   -> { readonly }
  belongs_to :submission_group_b, -> { readonly }, foreign_key: :submission_group_b_id, class_name: :SubmissionGroup
  belongs_to :prep_activity,      -> { readonly }, foreign_key: :prep_activity_id,      class_name: :ProgrammeActivity
  belongs_to :subm_activity,      -> { readonly }, foreign_key: :subm_activity_id,      class_name: :ProgrammeActivity
  belongs_to :dsr_doc_group,      -> { readonly }
  has_many   :dsr_submissions, dependent: :delete_all
  belongs_to :dsr_current_submission,              foreign_key: :dsr_current_submission_id, class_name: :DsrSubmission

  before_validation :set_defaults
  before_validation :update_plan_dates
  after_validation  :sync_baseline

  # scopes for filtering

  scope :ff_id,     -> ( did ){ where( id:                  did )}
  scope :ff_group,  -> ( grp ){ where( sender_group_id:     grp )}
  scope :ff_title,  -> ( txt ){ where( 'title LIKE ?', "%#{ txt }%" )}
  scope :ff_docgr,  -> ( dgr ){ where( dsr_doc_group_id:    dgr )}
  scope :ff_subgr,  -> ( sgr ){ where( submission_group_id: sgr )}
  scope :ff_docsts, -> ( sts ){ where( document_status:     sts )}
  scope :ff_wflsts, -> ( cst ){ where( current_status:      cst )}

  # validations - in alphabetical order

  validates :actl_completion, :actl_prep_start, :actl_submission_1,
    date_field: { presence: false }

  validates :current_status, :current_status_b,
    presence: true,
    numericality: { only_integer: true },
    inclusion: { in: 0..18 }

  validates :current_task, :current_task_b,
    presence: true,
    numericality: { only_integer: true },
    inclusion: { in: 0..10 }

  validate :dsr_doc_group_exists
  validate :dsr_current_submission_exists

  DSR_STATUS_RECORD_STATUS_LABELS = DsrStatusRecord.human_attribute_name( :document_states ).freeze

  validates :document_status, :document_status_b,
    presence: true,
    numericality: { only_integer: true },
    inclusion: { in: 0..( DSR_STATUS_RECORD_STATUS_LABELS.size - 1 )}

  validates :estm_completion, :estm_prep_start, :estm_submission, :next_submission,
    date_field: { presence: false }

  validate { given_programme_activity_exists( :prep_activity_id )}
  validate { given_programme_activity_exists( :subm_activity_id )}

  validates :quantity, :quantity_b,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :plnd_completion,   :plnd_prep_start,   :plnd_submission_1,
            :plnd_completion_b, :plnd_prep_start_b, :plnd_submission_b,
    date_field: { presence: false }

  validates :project_doc_id,
    allow_blank: true,
    length: { maximum: ProjectDocLog::MAX_LENGTH_OF_DOC_ID }

  validate { given_group_exists( :receiver_group_id )}

  validates :receiver_doc_id,
    allow_blank: true,
    length: { maximum: MAX_LENGTH_OF_DOC_ID }

  validates :sender_group_id,
    presence: true

  validate { given_group_exists( :sender_group_id )}

  validates :sender_doc_id,
    allow_blank: true,
    length: { maximum: MAX_LENGTH_OF_DOC_ID }

  DSR_SUB_PURPOSE_LABELS = DsrStatusRecord.human_attribute_name( :sub_purposes ).freeze

  validates :sub_purpose,
    presence: true,
    numericality: { only_integer: true },
    inclusion: {  in: 0..( DSR_SUB_PURPOSE_LABELS.size - 1 )}

  DSR_SUB_FREQUENCY_LABELS = DsrStatusRecord.human_attribute_name( :sub_frequencies ).freeze

  validates :sub_frequency,    
    allow_blank: true,
    numericality: { only_integer: true },
    inclusion: {  in: 0..( DSR_SUB_FREQUENCY_LABELS.size - 1 )}

  validate :submission_groups_exist
  
  validates :title,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_TITLE }

  validates :weight, :weight_b,
    allow_blank: true,
    numericality: { greater_than_or_equal_to: 0.0 }

  validate :quantity_frequency_combination
  validate :sub_purpose_submission_dates_combination
  validate :programme_activities_combination

  # helper functions (interface to ordered sets)

  def single_submission_frequency?
    sub_frequency == 0 or sub_frequency == 1
  end

  def submission_required?
    sub_purpose == 0 or sub_purpose == 1
  end

  def no_submission?
    sub_purpose == 3
  end

  private

  # if no submission is planned, there should be no
  # (a) subm_activity
  # (b) estm_submission date

  def sub_purpose_submission_dates_combination
    if no_submission? then
      errors.add( :base, I18n.t( 'dsr_status_records.msg.bad_sd_combo' )) \
        unless subm_activity_id.blank? and estm_submission.blank?
    end
  end

  # make sure that single submission frequencies have only a quantity of 1

  def quantity_frequency_combination
    unless errors.key?( :sub_frequency ) or errors.key?( :quantity ) then
      if quantity == 1 and !single_submission_frequency? then
        errors.add( :base, I18n.t( 'dsr_status_records.msg.bad_fq_combo' ))
      end
    end
  end

  # ensure that prepare/submit and review/approve activities are not the same

  def programme_activities_combination
    if prep_activity_id && subm_activity_id &&
       !errors.include?( :prep_activity_id ) && !errors.include?( :subm_activity_id ) then
      errors.add( :base, I18n.t( 'dsr_status_records.msg.bad_pa_combo' )) \
        unless prep_activity_id != subm_activity_id
    end
  end

  # callback before_save: update plnd_... dates

  def update_plan_dates
    self.plnd_prep_start = [ try( :prep_activity ).try( :start_date  ), estm_prep_start ].compact.max
    if submission_required? then
      self.plnd_submission_1 = [ try( :prep_activity ).try( :finish_date ), estm_submission ].compact.max
      self.plnd_completion   = [ try( :subm_activity ).try( :finish_date ), estm_completion ].compact.max
    else
      self.plnd_completion = [ try( :prep_activity ).try( :finish_date ), estm_completion ].compact.max
    end
  end

  # set default values

  def set_defaults
    set_nil_default( :quantity, 1 )
    set_nil_default( :weight, 1.0 )  
  end

  # make sure the given submission package record exists

  def submission_groups_exist
    if submission_group_id.present?
      errors.add( :submission_group_id, I18n.t( 'dsr_status_records.msg.bad_sgp_item' )) \
        unless SubmissionGroup.exists?( submission_group_id )
    end
    if submission_group_b_id.present?
      errors.add( :submission_group_b_id, I18n.t( 'dsr_status_records.msg.bad_sgp_item' )) \
        unless SubmissionGroup.exists?( submission_group_b_id )
    end
  end

  # make sure the document group exists AND the responsible groups
  # are identical

  def dsr_doc_group_exists
    if dsr_doc_group_id.present?
      errors.add( :dsr_doc_group_id, I18n.t( 'dsr_status_records.msg.bad_group_id' )) \
        unless DsrDocGroup.where( id: dsr_doc_group_id, group: sender_group_id ).exists?
    end
  end

  # make sure the referred to submission record exists

  def dsr_current_submission_exists
    if dsr_current_submission_id.present?
      errors.add( :dsr_current_submission_id, I18n.t( 'dsr_status_records.msg.bad_sub_rec' )) \
        unless DsrSubmission.exists?( dsr_current_submission_id )
    end
  end

  public

  # base line helpers:
  # save_baseline - copy all variables to baseline
  # init_baseline - initialize all baseline variables to a useful value
  # sync_baseline - make sure initial baseline corresponds to current settings, no-op else

  def save_baseline
    self.document_status_b     = document_status
    self.sender_group_b_id     = sender_group_id
    self.submission_group_b_id = submission_group_id
    self.quantity_b            = quantity
    self.weight_b              = weight
    self.plnd_prep_start_b     = plnd_prep_start
    self.plnd_submission_b     = plnd_submission_1
    self.plnd_completion_b     = plnd_completion
    self.current_status_b      = current_status
    self.current_task_b        = current_task
    self.baseline_date         = DateTime.now
  end

  def init_baseline
    self.document_status_b     = 0   # initial
    self.sender_group_b_id     = nil # because there should be a sync_baseline later
    self.submission_group_b_id = nil
    self.quantity_b            = 0
    self.weight_b              = 0.0
    self.plnd_prep_start_b     = nil
    self.plnd_submission_b     = nil
    self.plnd_completion_b     = nil
    self.current_status_b      = 0
    self.current_task_b        = 0
    self.baseline_date         = nil
  end

  private

  def sync_baseline
    if baseline_date.nil? && errors.empty?
      self.sender_group_b_id      = sender_group_id
      self.submission_group_b_id  = submission_group_id
    end
  end

  public

  # fix assignments

  def title=( text )
    write_attribute( :title, AppHelper.clean_up( text ))
  end

  def sender_doc_id=( text )
    write_attribute( :sender_doc_id, AppHelper.clean_up( text ))
  end

  def receiver_doc_id=( text )
    write_attribute( :receiver_doc_id, AppHelper.clean_up( text ))
  end

  def project_doc_id=( text )
    write_attribute( :project_doc_id, AppHelper.clean_up( text ))
  end

  # logic checks: all conditions met?

  def check_prepare_readiness
    errors.add( :weight, I18n.t( 'dsr_status_records.msg.bad_weight1' )) \
      unless weight && weight >= 0.0
    errors.add( :quantity, I18n.t( 'dsr_status_records.msg.bad_quantity1' )) \
      unless quantity.present? && quantity == 1
    errors.add( :sub_frequency, I18n.t( 'dsr_status_records.msg.bad_frequency' )) \
      unless single_submission_frequency?
  end    

  def check_submit_readiness
    errors.add( :sub_purpose, I18n.t( 'dsr_status_records.msg.bad_purpose' )) \
      unless submission_required?
  end

  def check_withdraw_readiness
    errors.add( :weight, I18n.t( 'dsr_status_records.msg.bad_weight0' )) \
      unless weight && weight.zero?
    errors.add( :quantity, I18n.t( 'dsr_status_records.msg.bad_quantity0' )) \
      unless quantity && quantity.zero?
  end

  def check_submit_for_info_only
    errors.add( :sub_purpose, I18n.t( 'dsr_status_records.msg.bad_state' )) \
      unless sub_purpose == 1
  end

  # collection of methods to help with the add functionality (derive new -
  # single submission - status record from existing - multiple submission)

  # basic check if it is possible to derive from this record

  def possible_to_derive?
    ( sub_frequency && sub_frequency > 1 )and 
    dsr_doc_group_id and # not dsr_doc_group_id.nil?
    ( quantity && quantity > 0 )and
    ( weight && weight > 0 )
  end

  # check if new record dsr_new can be derived from this record
  # (note: no need to check for nil as nil class has == method)

  def possible_to_derive_this( dsr_new )
    possible_to_derive? and
    dsr_new.sub_frequency == 1 and
    dsr_new.quantity == 1 and
    dsr_new.dsr_doc_group_id == self.dsr_doc_group_id
  end

  # actually derive dsr_new record from this by updating this

  def derive_this( dsr_new )
    self.quantity -= 1
    if dsr_new.weight >= weight then
      weight = 0.0
    else
      weight -= dsr_new.weight
    end
  end

  # retrieve group_code to display in index/show

  def sender_group_code
    ( sender_group.try :code ) || some_id( sender_group_id )
  end

  def sender_group_b_code
    ( sender_group_b.try :code ) || some_id( sender_group_b_id )
  end    

  def receiver_group_code
    ( receiver_group.try :code ) || some_id( receiver_group_id )
  end

  def submission_group_code
    ( submission_group.try :code ) || some_id( submission_group_id )
  end

  def doc_group_code
    ( dsr_doc_group.try :code ) || some_id( dsr_doc_group_id )
  end

  # return labels

  def document_status_label
    DSR_STATUS_RECORD_STATUS_LABELS[ document_status ] unless document_status.nil?
  end
  
  def document_status_b_label
    DSR_STATUS_RECORD_STATUS_LABELS[ document_status_b ] unless document_status_b.nil?
  end

  def sub_purpose_label 
    DSR_SUB_PURPOSE_LABELS[ sub_purpose ] unless sub_purpose.nil?
  end

  def sub_frequency_label 
    DSR_SUB_FREQUENCY_LABELS[ sub_frequency ] unless sub_frequency.nil?
  end

  def submission_package_label
    assoc_text_and_id( :submission_package, :label )
  end

  def activity_label( activity_type )
    assoc_text_and_id( activity_type, :activity_label )
  end

  # methods to determine whether a document is late:
  # soon_offset is the number of days to be considered for the
  # computation of 'almost/soon late'; by default, it is one
  # week = 7 days
  #
  # determine_late_status is the master-method, the public methods
  # can be used to determine a specific late-status.
  #
  # The possible results are
  #
  # 0 - undefined (no plan date specified)
  # 1 - currently late (plan date has passed, no actual date given)
  # 2 - currently open (but not late)
  # 3 - was late (plan date before actual date)
  # 4 - was on time (plan date on or after actual date)
  # 5 - currently almost late (plan date within soon_offset days of today)
  #
  # These methods are here for documentation purposes but I doubt if they
  # would really help a project other than putting blame on someone...

  private

  def determine_late_status( plan_date, actual_date, soon_offset )
    if plan_date.nil? then
      0 # need plan date to determine if doc is late
    else
      if actual_date.nil? then
        if plan_date.past? then
          1 # plan date is past - document is late
        elsif( plan_date - soon_offset ).past? then
          5 # note late but almost late
        else 
          2 # not almost late = not late
        end 
      else
        if plan_date < actual_date then
          3 # plan date before actual date = late
        else
          4 # plan date same or after actual date = not late
        end
      end
    end
  end

  public

  def determine_late_prep( soon_offset = 7 )
    determine_late_status( plnd_prep_start, actl_prep_start, soon_offset )
  end

  def determine_late_subm( soon_offset = 7 )
    determine_late_status( plnd_submission_1, actl_submission_1, soon_offset )
  end

  def determine_late_compl( soon_offset = 7 )
    determine_late_status( plnd_completion, actl_completion, soon_offset )
  end

end
