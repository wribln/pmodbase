class CfrLocationType < ActiveRecord::Base
  include ApplicationModel

  validates :label,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  LOCATION_TYPE_LABELS = CfrLocationType.human_attribute_name( :location_types ).freeze

  validates :location_type,
    allow_nil: true,
    inclusion: { in: 0..( LOCATION_TYPE_LABELS.size - 1 )}

  validates :path_prefix,
    uniqueness: true,
    length: { maximum: MAX_LENGTH_OF_STRING }

  validate :path_prefix_syntax

  validates :concat_char,
    length: { maximum: MAX_LENGTH_OF_CODE }

  validates :project_dms,
    inclusion: { in: [ true, false ]}

  validates :note,
    length: { maximum: MAX_LENGTH_OF_NOTE }

  validate :one_project_dms_only

  set_trimmed :concat_char, :label, :note, :path_prefix

  # make sure there is only one record with project_dms true

  def one_project_dms_only
    if project_dms then
      if self.class.where( project_dms: true ).where.not( id: id ).count > 0 then
        errors.add( :project_dms, I18n.t( 'cfr_location_types.msg.only_one_pdms' ))
      end
    end
  end

  # check path_prefix according to location_type

  def path_prefix_syntax
    return if path_prefix.blank?
    return if errors.include?( :path_prefix )
    r = case location_type
    when 0 # windows drive
      /\A[a-z]:\\([^\\\/?|><:*"]+\\)*[^\\\/?|><:*"]*\z/i
    when 1 # unix drive
      /\A\/([^\/?*|><]+\/)*[^\/?*|><]*\z/
    when 2 # Sharepoint
      /\Ahttps:\/\/www.workspace.siemens.com\/content\/\d+\/s\/Forms\/AllItems.aspx?(?:[A-Za-z0-9\-._~!$&'()*+,;=:@\/?]|%[0-9A-Fa-f]{2})*\z/
    when 3 # Aconex
      /\Ahttps:\/\/\w+.aconex.com\/Logon?(?:[A-Za-z0-9\-._~!$&'()*+,;=:@\/?]|%[0-9A-Fa-f]{2})*\z/
    when 4 # internet
      /\A(https?|ftp|file):\/\/.+\z/i
    end
    errors.add( :path_prefix, I18n.t( 'cfr_location_types.msg.bad_path' ))\
      unless r =~ path_prefix
  end

  # retrieve file name and extension from given path - if possible

  def extract_file_name( path )
    return if path.blank?
    r = case location_type
    when 0 # windows drive
      /([^\\\/?|><:*"]+)\z/i
    when 1 # unix drive
      /([^\/?*|><]+)\z/
    when 2 # sharepoint
      return nil # not possible at this time
    when 3 # aconex
      return nil # not possible
    when 4 # internet
      /\A(?:(?:https?|file):\/\/(?:[^\\\/]+[\\\/])*)([^\\\/?|><:*"]+)\z/
    else # don't even try it - you never know what's in front of the file name!
      return nil
    end
    r.match( path ){ |m| m[ 1 ]}
    #/[^\\\/]+(\.[^\\\/\.]+)?\z/.match( path ){ |m| m[ 0 ]}
  end

  # compare given file path with current path prefix and return true if
  # path prefix is really prefix of file path

  def same_location?( path )
    return false if path.blank?
    return false if path_prefix.nil?
    return false if path_prefix.length >= path.length
    case location_type
    when 0 # windows drive: ignore case of drive letter
      path[ 0 ].casecmp( path_prefix[ 0 ]) &&
      path[ 1, path_prefix.length - 1 ] == path_prefix[ 1, path_prefix.length - 1 ]
    when 1, 2, 3, 4 # case-sensitive compare
      path[ 0, path_prefix.length ] == path_prefix
    else
      false
    end
  end

  # find the best match for a given path within all records, returns
  # location type with best match

  def self.find_location_type( file_path )
    return if file_path.blank?
    lt_max_match = 0
    lt_best = nil
    CfrLocationType.all.each do |lt|
      if lt.same_location?( file_path )
        lt_max_match = lt.path_prefix.length 
        lt_best = lt
      end
    end
    return lt_best
  end

  # attempt to determine extension from file name

  def self.get_extension( file_name )
    /[^\\\/]+\.([^\\\/\.]+)\z/.match( file_name ){ |m| m[ 1 ]}
  end

  # give me only the file name without extension

  def self.get_file_name( file_name, extension )
    file_name.try( :gsub, /\.#{ extension }\z/, '' )
  end

  # combine doc code and a doc version strings using concat_char
  # returns empty string if both doc_code and doc_version are not
  # available

  def complete_code( doc_code, doc_version )
    ( doc_code.blank? && doc_version.blank? ) ? '' : doc_code.to_s + concat_char.to_s + doc_version.to_s
  end

  # provide label for location type

  def location_type_label
    location_type.nil? ? '' : LOCATION_TYPE_LABELS[ location_type ]
  end

end
