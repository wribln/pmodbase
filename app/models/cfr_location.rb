require './lib/assets/app_helper.rb'
class CfrLocation < ActiveRecord::Base

  belongs_to :cfr_record, inverse_of: :cfr_locations
  belongs_to :cfr_record, inverse_of: :main_location
  belongs_to :cfr_location_type

  validates :file_name,
    allow_nil: true,
    length: { maximum: MAX_LENGTH_OF_STRING }

  validates :doc_code,
    allow_nil: true,
    length: { maximum: MAX_LENGTH_OF_DOC_ID }

  validates :doc_version,
    allow_nil: true,
    length: { maximum: MAX_LENGTH_OF_DOC_VERSION }

  validates :uri,
    allow_nil: true,
    length: { maximum: MAX_LENGTH_OF_URI }

  validates :cfr_record,
    presence: true

  validate :given_location_type_exists
  validate :given_cfr_record_exists

  # this is only to help cfr_record to determine which location is the main location
  # see comments there

  validates :is_main_location,
    inclusion: { in: [ true, false ]}

  # make sure we have no leading and trainling whitespaces

  def uri=( s )
    write_attribute( :uri, AppHelper.clean_up( s ))
  end

  def file_name=( s )
    write_attribute( :file_name, AppHelper.clean_up( s ))
  end

  def doc_code=( s )
    write_attribute( :doc_code, AppHelper.clean_up( s ))
  end

  def doc_version=( s )
    write_attribute( :doc_version, AppHelper.clean_up( s ))
  end

  # check if cfr_location_type record exists

  def given_location_type_exists
    if cfr_location_type_id.present?
      errors.add( :cfr_location_type_id, I18n.t( 'cfr_locations.msg.bad_loc_type' )) \
        unless CfrLocationType.exists?( cfr_location_type_id )
    end
  end

  # check if cfr_record exists

  def given_cfr_record_exists
    if cfr_record_id.present?
      errors.add( :cfr_record_id, I18n.t( 'cfr_locations.msg.bad_cfr_rec' )) \
        unless CfrRecord.exists?( cfr_record_id )
    end
  end

  # attempt to determine default values from given attributes

  def set_defaults
    unless uri.blank? then
      if cfr_location_type.blank? then
         self.cfr_location_type = CfrLocationType.find_location_type( uri )
      end
      if file_name.blank? && cfr_location_type then
        self.file_name = cfr_location_type.extract_file_name( uri )
      end
    end
  end

  # prepare hyperlink for display

  def get_hyperlink
    /\A(https?|file|ftp):\/\//i =~ uri ? uri : 'file://' + uri unless uri.blank?
  end

end
