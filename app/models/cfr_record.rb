class CfrRecord < ActiveRecord::Base
  include ApplicationModel
  include Filterable
  include GroupCheck
  include CfrFileTypeCheck

  belongs_to :group,         -> { readonly }
  belongs_to :cfr_file_type, -> { readonly }
  belongs_to :main_location, foreign_key: 'main_location_id', class_name: 'CfrLocation', inverse_of: :cfr_record
  has_many   :cfr_locations, inverse_of: :cfr_record
  accepts_nested_attributes_for :cfr_locations, allow_destroy: true, reject_if: :location_empty

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

  validates :cfr_file_type_id,
    allow_nil: true,
    numericality: { only_integer: true, greater_then: 0, message: I18n.t( 'cfr_records.msg.bad_ft_id' )}

  validate :given_file_type_exists    

  validates :group_id,
    allow_nil: true,
    numericality: { only_integer: true, greater_than: 0, message: I18n.t( 'cfr_records.msg.bad_group_id' )}

  validate :given_group_exists

  HASH_FUNCTION_LABELS = CfrRecord.human_attribute_name( :hash_functions ).freeze

  validates :hash_function,
    allow_nil: true,
    inclusion: { in: 0..( HASH_FUNCTION_LABELS.size - 1 )}

  validates :hash_value,
    allow_nil: true,
    format: { with: /\A\h+\z/, message: I18n.t( 'cfr_records.msg.hex_only' )}

  validate :hash_function_and_value

  validates :main_location_id,
    allow_nil: true,
    numericality: { only_integer: true, greater_than: 0, message: I18n.t( 'cfr_records.msg.bad_loc_id' )}

  validate :given_main_location_ok

  validates :note,
    length: { maximum: MAX_LENGTH_OF_DESCRIPTION }

  # title is only mandatory if there is no file name specified for the main location:
  # otherwise use the file name (w/o extension) as default title.

  validates :title,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_TITLE }

  # all permitted: all groups for this account, check for conf_level must be done on a
  # group by group basis within views

  scope :all_permitted, ->( a ){ self.permitted_records( a, :to_index )}
  default_scope { order( id: :desc )}

  # filter scopes

  scope :ff_id, ->   ( i ){ where id: i }
  scope :ff_text, -> ( t ){ where( 'title LIKE :param OR note LIKE :param', param: "%#{ t }%" )}
  scope :ff_type, -> ( t ){ where cfr_file_type_id: t }
  scope :ff_grp, ->  ( g ){ where group_id: g }

  # check if cfr_location is empty - except when we are creating a new record
  # return true if record should be rejected and destroyed

  def location_empty( attributes )
    if new_record? then
      return false
    else
      attributes[ :uri ].blank? &&
      attributes[ :file_name   ].blank? &&
      attributes[ :doc_code    ].blank? &&
      attributes[ :doc_version ].blank?
    end
  end

  # test if main location points back to this cfr record

  def given_main_location_ok
    return if errors.include?( :main_location_id )
    return unless main_location_id.present?
    errors.add( :main_location_id, I18n.t( 'cfr_records.msg.bad_main_loc' )) \
      unless main_location.cfr_record == self && main_location.is_main_location
  end

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
    cfr_file_type_id.nil? ? '' : self.cfr_file_type.label
  end

  # provide a link form the main location to the file

  def link_to_file
    return nil unless main_location.present?
    main_location.get_hyperlink
  end

end
