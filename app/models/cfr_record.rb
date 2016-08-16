require './lib/assets/app_helper.rb'
class CfrRecord < ActiveRecord::Base
  include ApplicationModel
  include Filterable

  belongs_to :group,         -> { readonly }
  belongs_to :cfr_file_type, -> { readonly }
  belongs_to :main_location, foreign_key: 'main_location_id', class_name: 'CfrLocation', inverse_of: :cfr_record
  has_many   :src_relations, dependent: :destroy, foreign_key: 'src_record_id', class_name: 'CfrRelation', inverse_of: :src_record
  has_many   :dst_relations, dependent: :destroy, foreign_key: 'dst_record_id', class_name: 'CfrRelation', inverse_of: :dst_record
  has_many   :cfr_locations, dependent: :destroy, inverse_of: :cfr_record
  has_many   :main_locations, -> { where( is_main_location: true )}, class_name: 'CfrLocation'
  accepts_nested_attributes_for :cfr_locations, allow_destroy: true, reject_if: :location_empty?
  accepts_nested_attributes_for :src_relations, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :dst_relations, allow_destroy: true, reject_if: :all_blank

  CONF_LEVEL_LABELS = CfrRecord.human_attribute_name( :conf_levels ).freeze

  validates :conf_level,
    presence: true,
    inclusion: { in: 0..( CONF_LEVEL_LABELS.size - 1 )}

  validates :doc_date,
    length: { maximum: MAX_LENGTH_OF_DOC_DATE }

  validates :doc_owner,
    length: { maximum: MAX_LENGTH_OF_ACCOUNT_INFO }

  validates :doc_version,
    length: { maximum: MAX_LENGTH_OF_DOC_VERSION }

  validates :extension,
    length: { maximum: MAX_LENGTH_OF_EXTENSION }

  validates :cfr_file_type,
    presence: true, if: Proc.new{ |me| me.cfr_file_type_id.present? }

  validates :group,
    presence: true, if: Proc.new{ |me| me.group_id.present? }

  HASH_FUNCTION_LABELS = CfrRecord.human_attribute_name( :hash_functions ).freeze

  validates :hash_function,
    allow_nil: true,
    inclusion: { in: 0..( HASH_FUNCTION_LABELS.size - 1 )}

  validates :hash_value,
    allow_nil: true,
    format: { with: /\A\h+\z/, message: I18n.t( 'cfr_records.msg.hex_only' )}

  validate :hash_function_and_value

  #validate :given_main_location_ok

  validates :note,
    length: { maximum: MAX_LENGTH_OF_DESCRIPTION }

  # title is only mandatory if there is no file name specified for the main location:
  # otherwise use the file name (w/o extension) as default title.

  validates :title,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_TITLE }

  validate :all_main_locations

  # all permitted: all groups for this account, check for conf_level must be done on a
  # group by group basis within views

  scope :all_permitted, ->( a ){ self.permitted_records( a, :to_index )}
  default_scope { order( id: :desc )}

  # filter scopes

  scope :ff_id, ->   ( i ){ where id: i }
  scope :ff_text, -> ( t ){ 
    joins( 'LEFT JOIN cfr_locations ON cfr_records.id = cfr_locations.cfr_record_id' ).
    where( 'title LIKE :param OR note LIKE :param OR cfr_locations.doc_code LIKE :param', param: "%#{ t }%" )}
  scope :ff_type, -> ( t ){ where cfr_file_type_id: t }
  scope :ff_grp, ->  ( g ){ where group_id: g }

  # get all relations

  def all_relations
    CfrRelation.where( 'src_record_id = :id OR dst_record_id = :id', id: "#{ self.id }").includes( :cfr_relationship )
  end

  # check if cfr_location is empty - except when we are creating a new record
  # return true if record should be rejected and destroyed. Important note:
  # this method is only called when creating a new CfrRecord from a hash; it
  # it NOT called for saves!

  def location_empty?( attr )
    attr[ 'uri'         ].blank? &&
    attr[ 'file_name'   ].blank? &&
    attr[ 'doc_code'    ].blank? &&
    attr[ 'doc_version' ].blank?
  end

  # = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
  # I added these after the design of the data structure because
  # it was quite difficult to set the main_location in view and
  # controller without complex Javascript fiddling: I added a
  # is_main_location flag in each CfrLocation record so I could
  # determine after saving the CfrRecord and all associated Cfr-
  # Locations which of the CfrLocations would be the main
  # location. Note: I think it is more efficient to have a direct
  # link to the main location rather than shooting a query each
  # time I need it.

  def update_main_location
    update_attribute( :main_location, self.main_locations.try( :first ))
  end

  def all_main_locations
    errors.add( :base, I18n.t( 'cfr_records.msg.too_many_mains' )) \
      if cfr_locations.find_all{ |x| x[ :is_main_location ] && !x.marked_for_destruction? }.length > 1
  end

  # the following validation method CANNOT be called during the 
  # normal validation as the main_location is only known after 
  # all cfr_locations are saved and update_main_location is done.
  # however, this may be used for any sanity checks:

  def given_main_location_ok
    errors.add( :main_location, :blank ) \
      unless main_location && main_location.cfr_record == self && main_location.is_main_location
  end

  # = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 

  # prepare condition to restrict access to permitted groups for this user
  # this is patterned after Group.permitted_groups but considers here two
  # attributes ... to be used in queries

  def self.permitted_records( account, action )
    pg = account.permitted_groups( FEATURE_ID_CFR_RECORDS, action )
    case pg
    when nil
      where( conf_level: 0 ).where( 'group_id IS NULL' )
    when ''
      all
    else
      where( 'group_id IN ( ? )', pg )
    end      
  end

  # make sure that length of hash value corresponds to function - if given
  # avoid more than one error message per attribute

  def hash_function_and_value
    return if hash_value.nil?
    if hash_function.nil? then
      return if errors.include?( :hash_value )
      errors.add( :hash_value, I18n.t( 'cfr_records.msg.hash_wo_fct' ))
    else
      case hash_function
      when 0 # MD5
        hash_size = 32
      when 1 # SHA-256
        hash_size = 64
      else
        return if errors.includes( :hash_function )
        errors.add( :hash_function, I18n.t( 'cfr_records.msg.unknown_fct' ))
        return
      end
      if hash_value.length != hash_size then
        return if errors.include?( :hash_value )
        errors.add( :hash_value, :wrong_length, count: hash_size )
      end
    end
  end

  # remove all blanks from hash value, map to lowercase for better reading

  def hash_value=( text )
    t = text.gsub( ' ','' ).downcase unless text.nil?
    write_attribute( :hash_value, t.blank? ? nil : t )
  end

  # display group code - if possible

  def group_code
    group_id.nil? ? '' : group.code
  end

  # display hash function label or blank

  def hash_function_label
    hash_function.nil? ? '' : HASH_FUNCTION_LABELS[ hash_function ]
  end

  def file_type_label
    cfr_file_type_id.nil? ? '' : cfr_file_type.label
  end

  # provide a link form the main location to the file

  def link_to_file
    main_location.present? ? main_location.get_hyperlink : nil
  end

end
