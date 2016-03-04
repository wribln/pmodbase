class DsrProgressRate < ActiveRecord::Base
  include ApplicationModel

  has_many :dsr_status_records, { foreign_key: :document_status }

  self.primary_key = :document_status
  
  validates :document_status,
    uniqueness: true,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0 }

  validates :document_progress, :prepare_progress, :approve_progress,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to:  100 }

  # some utilities / api methods rely on the availability of the id variable
  # so I just provide it

  def id
    document_status
  end

end
