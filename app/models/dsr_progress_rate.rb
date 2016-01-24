class DsrProgressRate < ActiveRecord::Base
  include ApplicationModel

  has_many :dsr_status_records, { foreign_key: :document_status }
  
  validates :document_progress, :prepare_progress, :approve_progress,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to:  100 }

end
