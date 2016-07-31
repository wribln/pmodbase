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
        unless CfrLocationType.exists?( cfr_record_id )
    end
  end

  # attempt to determine default values from given attributes

  def set_defaults
    unless uri.blank? then
      if cfr_location_type.blank? then
         self.cfr_location_type = CfrLocationType.find_location_type( uri )
      end
      if self.file_name.blank? && self.cfr_location_type then
        self.file_name = cfr_location_type.extract_file_name( uri )
      end
    end
  end

end