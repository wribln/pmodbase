require "./lib/assets/app_helper.rb"
class SubmissionGroup < ActiveRecord::Base
  include ApplicationModel
  include ProgrammeActivityCheck

  has_many :dsr_documents, inverse_of: :submission_group

  validates :code,
    length: { maximum: MAX_LENGTH_OF_CODE },
    presence: true,
    uniqueness: true

  validates :label,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  default_scope { order( code: :asc )}

  # overwrite write accessors to ensure that text fields do not contain
  # any redundant blanks

  def code=( text )
    write_attribute( :code, AppHelper.clean_up( text ))
  end

  def label=( text )
    write_attribute( :label, AppHelper.clean_up( text ))
  end

  def code_with_id
    text_and_id( :code ) 
  end

end
