require "./lib/assets/app_helper.rb"
class DbChangeRequest < ActiveRecord::Base
  include ApplicationModel
  include FeatureCheck

  belongs_to :req_account,  -> { readonly }, foreign_key: 'requesting_account_id',  class_name: 'Account'
  belongs_to :resp_account, -> { readonly }, foreign_key: 'responsible_account_id', class_name: 'Account'
  belongs_to :feature,      -> { readonly }

  # required, with existing account

  validates :requesting_account_id,
    presence: true

  validate { given_account_exists( :requesting_account_id  )}
  validate { given_account_exists( :responsible_account_id )}

  validates :feature_id,
    allow_nil: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :given_feature_exists

  validates :detail,
    length: { maximum: MAX_LENGTH_OF_LABEL } 

  validates :action,
    length: { maximum: MAX_LENGTH_OF_CODE }

  # current status handling
  # 0 - new (just created, not assigned)
  # 1 - open (assigned to responsible account)
  # 2 - wait (for others)
  # 3 - closed

  DBCR_STATUS_LABELS = DbChangeRequest.human_attribute_name( :states ).freeze

  validates :status,
    numericality: { only_integer: true },
    inclusion: { in: 0..( DBCR_STATUS_LABELS.size - 1 )}

  validates :uri,
    length: { maximum: MAX_LENGTH_OF_URI }

  validates :request_text,
    presence: true

  scope :for_user, -> ( id ){ where requesting_account_id: id }

  def status_label_with_id
    some_text_and_id( DBCR_STATUS_LABELS[ self.status ], self.status ) unless self.status.nil?
  end

  def requestor_with_id
    ( req_account.assoc_text_and_id( :person, :name ) if req_account.present? ) || some_id( requesting_account_id )
  end

  def responsible_with_id
    ( resp_account.assoc_text_and_id( :person, :name ) if resp_account.present? ) || some_id( responsible_account_id )
  end

  def feature_label_with_id
    assoc_text_and_id( :feature, :label )
  end

  # check if related records exist

  def given_account_exists( name )
    if send( name ).present?
      errors.add( name, I18n.t( 'db_change_requests.msg.bad_account_id' )) \
        unless Account.exists?( send( name ))
    end
  end

  # overwrite write accessors to ensure that text field is filled to max possible

  def uri=( text )
    write_attribute( :uri, AppHelper.fix_string( text, MAX_LENGTH_OF_URI ))
  end

  # extend statistics

  def self.get_stats
    super.concat( DbChangeRequest.group( :status ).count.map{ |k,v| [ DBCR_STATUS_LABELS[ k ], v ]}.sort )
  end

end
