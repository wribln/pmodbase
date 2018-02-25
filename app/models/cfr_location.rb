require './lib/assets/app_helper.rb'
require 'cgi'
class CfrLocation < ActiveRecord::Base
  include ApplicationModel
  include ActiveModelErrorsAdd

  belongs_to :cfr_record, optional: true, inverse_of: :cfr_locations
  belongs_to :cfr_record, optional: true, inverse_of: :main_location
  belongs_to :cfr_location_type, -> { readonly }, optional: true

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

  validates :cfr_location_type,
    presence: true, if: Proc.new{ |me| me.cfr_location_type_id.present? }

  validate :location_type_and_uri

  # this is only to help cfr_record to determine which location is the main location
  # see comments there; needs to be an integer in the database as boolean is not a
  # standard data type in SQL and I need to be able to sort by this field correctly 
  # (is_main_location should be first for all databases); implemented to be boolean
  # in model, integer internally (see getter/setter methods)

  validates :is_main_location,
    inclusion: { in: [ false, true ]}

  set_trimmed :uri, :file_name, :doc_code, :doc_version

  # getter/setter for is_main_location

  def is_main_location=( b )
    write_attribute( :is_main_location, b ? 1 : 0 )
  end

  def is_main_location
    read_attribute( :is_main_location ) == 0 ? false : true
  end

  # ensure that prefix of cfr_location_type matches uri

  def location_type_and_uri
    if cfr_location_type && uri.present? then
      errors.add( :base, I18n.t( 'cfr_locations.msg.uri_bad_type' )) \
        unless cfr_location_type.same_location?( uri )
    end
  end

  # attempt to determine default values from given attributes

  def set_defaults
    unless uri.blank? then
      if cfr_location_type.blank? then
         self.cfr_location_type = CfrLocationType.find_location_type( uri )
      end
      if file_name.blank? then
        self.file_name = cfr_location_type.try( :extract_file_name, uri )
        self.file_name = CGI.unescape( self.file_name ) if /%\h\h/.match( self.file_name )
      end
    end
  end

  # return hyperlink for display - but only if there is an associated location type

  def get_hyperlink
    unless cfr_location_type_id.nil? || uri.blank? 
      /\A(https?|file|ftp):\/\//i =~ uri ? uri : "file://#{ uri }"
    end
  end

  # helper function: display document code and version if no location type present

  def complete_code
    cfr_location_type.present? ? cfr_location_type.complete_code( doc_code, doc_version ) : ( doc_code + ' - ' + doc_version )
  end

end
