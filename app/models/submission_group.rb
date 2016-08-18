require "./lib/assets/app_helper.rb"
class SubmissionGroup < ActiveRecord::Base
  include ApplicationModel

  has_many :dsr_documents, inverse_of: :submission_group

  validates :code,
    length: { maximum: MAX_LENGTH_OF_CODE },
    presence: true,
    uniqueness: true

  validates :label,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  set_trimmed :code, :label

  default_scope { order( code: :asc )}

  def code_with_id
    text_and_id( :code ) 
  end

end
