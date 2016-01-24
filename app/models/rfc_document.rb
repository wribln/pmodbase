require './lib/assets/app_helper.rb'
class RfcDocument < ActiveRecord::Base
  include ApplicationModel
  include RfcStatusRecordCheck
  include AccountCheck
  include Filterable

  belongs_to :rfc_status_record, -> { readonly }, inverse_of: :rfc_documents
  belongs_to :account,           -> { readonly }, inverse_of: :rfc_documents

  # there must always be an associated RfC Status Record

  validates :rfc_status_record_id,
    presence: true,
    numericality: { only_integer: true, greater_than: 0 }

  validate :given_rfc_status_record_exists

  # there must always be the account which made this change

  validates :account_id,
    presence: true,
    numericality: { only_integer: true, greater_than: 0 }

  validate :given_account_exists

  validates :version,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal: 0 }

  default_scope { order( rfc_status_record_id: :asc, version: :desc )}
  scope :ff_srec, -> ( id ){ where rfc_status_record_id: id }

  # list attributes in the order to be processed

  DATA_ATTRIBUTES = [ :note, :question, :answer ]

  # compare this with another RfcDocument and determine whether
  # there are any differences between those two instances in respect
  # to the data_attributes to be compared

  def modified?( original )
    DATA_ATTRIBUTES.any? { |e| send( e ) != original.send( e )}
  end

  # returns true if version is 0 and all fields contain the initial 
  # empty values

  def initial_version?
    version.zero? && DATA_ATTRIBUTES.all? { |e| send( e ).blank? }
  end

end
