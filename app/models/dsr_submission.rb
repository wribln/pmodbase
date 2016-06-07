require './lib/assets/app_helper.rb'
class DsrSubmission < ActiveRecord::Base
  include ApplicationModel
  include Filterable

  before_save :compute_xpcd_response

  belongs_to :dsr_status_record, -> { readonly }

  scope :ff_dsr,  -> ( dsr  ){ where dsr_status_record_id: dsr }
  scope :ff_sdoc, -> ( sdoc ){ where( 'submission_project_doc_id LIKE ?', "%#{ sdoc }%")}
  scope :ff_rdoc, -> ( rdoc ){ where( 'response_project_doc_id LIKE ?',   "%#{ rdoc }%")}
  scope :ff_sdat, -> ( sdat ){ where actl_submission: sdat }
  scope :ff_rdat, -> ( rdat ){ where actl_response:   rdat }
  scope :ff_stat, -> ( stat ){ where response_status: stat }

  scope :default_order, -> { order( :dsr_status_record_id, :submission_no )}
  scope :mr_submission, -> ( dsr ){ where( dsr_status_record_id: dsr ).reorder( submission_no: :desc )}

  attr_accessor :xpcd_response_delta

  validates :dsr_status_record_id,
    presence: true

  validates :submission_no,
    presence: true,
    numericality: { only_integer: true, greater_than: 0 },
    uniqueness: { scope: :dsr_status_record_id, message: I18n.t( 'dsr_submissions.msg.not_unique' )}

  validates :plnd_submission, :actl_submission, :xpcd_response, :actl_response,
    date_field: { presence: false }

  validates :xpcd_response_delta,
    numericality: { only_integer: true, allow_blank: true }

  DSR_RESPONSE_STATUS_LABELS = DsrSubmission.human_attribute_name( :response_states ).freeze
  DSR_RESPONSE_STATUS_A = 0
  DSR_RESPONSE_STATUS_B = 1
  DSR_RESPONSE_STATUS_C = 2
  DSR_RESPONSE_STATUS_D = 3

  validates :response_status,
    allow_nil: true,
    numericality: { only_integer: true },
    inclusion: { in: 0..( DSR_RESPONSE_STATUS_LABELS.size - 1 )}

  validate :given_dsr_status_record_exists
  validate :response_dates_after_submission

  # make sure related record exists

  def given_dsr_status_record_exists
    errors.add( :dsr_status_record_id, I18n.t( 'dsr_submissions.msg.bad_dsr_id')) \
      unless DsrStatusRecord.exists?( dsr_status_record_id )
  end

  # make sure (computed) response dates are after the submission date

  def response_dates_after_submission
    unless actl_submission.blank?
      xpcd_response_computed = ( xpcd_response || Date.today ) + xpcd_response_delta.to_i
      errors.add( :xpcd_response, I18n.t( 'dsr_submissions.msg.bad_resp_date')) \
        unless xpcd_response_computed >= actl_submission
    end
  end

  # store the computed expected response date and clear the delta

  def compute_xpcd_response
    unless xpcd_response_delta.to_i.zero?
      self.xpcd_response = ( self.xpcd_response || Date.today ) + self.xpcd_response_delta.to_i
      self.xpcd_response_delta = 0
    end
  end

  # reset all fields (when submission not done)

  def reset_fields
    self.sender_doc_id_version = nil
    self.receiver_doc_id_version = nil
    self.project_doc_id_version = nil
    self.submission_receiver_doc_id = nil
    self.submission_project_doc_id = nil
    self.response_sender_doc_id = nil
    self.response_project_doc_id = nil
    self.plnd_submission = nil
    self.actl_submission = nil
    self.xpcd_response = nil
    self.actl_response = nil
    self.response_status = nil
  end    

  # return labels

  def response_status_label
    DSR_RESPONSE_STATUS_LABELS[ response_status ] unless response_status.nil?
  end

  # fix assignments

  def sender_doc_id_version=( text )
    write_attribute( :sender_doc_id_version, AppHelper.clean_up( text ))
  end

  def receiver_doc_id_version=( text )
    write_attribute( :receiver_doc_id_version, AppHelper.clean_up( text ))
  end

  def project_doc_id_version=( text )
    write_attribute( :project_doc_id_version, AppHelper.clean_up( text ))
  end    

  def submission_receiver_doc_id=( text )
    write_attribute( :submission_receiver_doc_id, AppHelper.clean_up( text ))
  end

  def submission_project_doc_id=( text )
    write_attribute( :submission_project_doc_id, AppHelper.clean_up( text ))
  end

  def response_sender_doc_id=( text )
    write_attribute( :response_sender_doc_id, AppHelper.clean_up( text ))
  end

  def response_project_doc_id=( text )
    write_attribute( :response_project_doc_id, AppHelper.clean_up( text ))
  end

end
