require './lib/assets/app_helper.rb'
class ContactInfo < ActiveRecord::Base
  include ApplicationModel
  include PersonCheck
  include AddressCheck

  belongs_to :person, inverse_of: :contact_infos
  belongs_to :address
  before_save :set_defaults

  validates :person_id,
    presence: true
 
  validate :given_person_exists

  validate :given_address_exists

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

  # overwrite write accessors to ensure that text fields do not contain
  # any redundant blanks

  def info_type=( text )
    write_attribute( :info_type, AppHelper.clean_up( text ))
  end

  def detail_location=( text )
    write_attribute( :detail_location, AppHelper.clean_up( text ))
  end

  def department=( text )
    write_attribute( :department, AppHelper.clean_up( text ))
  end
  
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
