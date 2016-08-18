require './lib/assets/app_helper.rb'
class ContactInfo < ActiveRecord::Base
  include ApplicationModel
  include ActiveModelErrorsAdd

  belongs_to :person, inverse_of: :contact_infos
  belongs_to :address
  before_save :set_defaults

  validates :person,
    presence: true

  validates :address,
    presence: true, if: Proc.new{ |me| me.address_id.present? } 

  validates :info_type,
    presence: true,
    uniqueness: { scope: :person_id, message: I18n.t( 'contact_infos.msg.no_dup_types') },
    length: { maximum: MAX_LENGTH_OF_INFORMATION_TYPE } 

  validates :detail_location,
    allow_blank: true,
    length: { maximum: MAX_LENGTH_OF_LOCATION_DETAIL }

  validates :department,
    allow_blank: true,
    length: { maximum: MAX_LENGTH_OF_DEPARTMENT }

  validates :phone_no_fixed,
    allow_blank: true,
    length: { maximum: MAX_LENGTH_OF_PHONE_NUMBER }

  validates :phone_no_mobile,
    allow_blank: true,
    length: { maximum: MAX_LENGTH_OF_PHONE_NUMBER }

  set_trimmed :info_type, :detail_location, :department

  # provide address label

  def address_label
    self.address.try( :label )
  end

  # set default values

  def set_defaults
    set_nil_default( :detail_location, '' )
    set_nil_default( :department,      '' )
    set_nil_default( :phone_no_fixed,  '' )
    set_nil_default( :phone_no_mobile, '' ) 
  end

end
