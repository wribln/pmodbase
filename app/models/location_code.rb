require './lib/assets/app_helper.rb'
class LocationCode < ActiveRecord::Base
  include ApplicationModel
  include Filterable
  include LocationCodeHelper

  before_validation :compute_missing_points

  has_many :network_lines
  has_many :network_stops

  validates :code,
    presence: true,
    uniqueness: true,
    format: { with: Regexp.union( /\A\+!\z/,/\A\+[A-Z0-9.\-]+\z/ ), message: I18n.t( 'code_modules.msg.bad_code_syntax' )},
    length: { maximum: MAX_LENGTH_OF_CODE }

  #validate :code_has_prefix # not needed: prefix is part of code validation

  validates :label,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  LOCATION_CODE_TYPES = LocationCode.human_attribute_name( :loc_types ).freeze

  validates :loc_type,
    presence: true,
    numericality: { only_integer: true },
    inclusion: { in: 0..( LOCATION_CODE_TYPES.size - 1 )}

  validates :center_point, :start_point, :end_point,
    allow_blank: true,
    numericality: { only_integer: true }

  validate :point_relationship

  validates :length,
    allow_blank: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :note,
    length: { maximum: MAX_LENGTH_OF_NOTE }

  default_scope { order( code: :asc )}
  scope :as_code, -> ( c ){ where( 'code  LIKE ?',  has_code_prefix( c ) ? "#{ c }%" : "#{ code_prefix }#{ c }%" )}
  scope :as_desc, -> ( l ){ where( 'label LIKE ?', "%#{ l }%" )}
  scope :ff_type, -> ( t ){ where( loc_type: t )}

  # add code_model features

  class << self
    attr_accessor :code_prefix
  end

  @code_prefix = '+'
 
  def self.has_code_prefix( c )
    c && c[ 0 ] == @code_prefix
  end

  # overwrite write accessors to ensure that text fields do not contain
  # any redundant blanks 

  def code=( text )
    write_attribute( :code, AppHelper.clean_up( text, MAX_LENGTH_OF_CODE ))
  end

  def label=( text )
    write_attribute( :label, AppHelper.clean_up( text, MAX_LENGTH_OF_LABEL ))
  end

  # note: use '#{ self.class.table_name }' instead of 'code_modules' if you want
  #       to use table-specific error messages

  # make sure the given code includes the class prefix
  
  def code_has_prefix
    errors.add( :code, I18n.t( 'code_modules.msg.bad_code_format', prefix: self.class.code_prefix )) \
      unless self.class.has_code_prefix( code )
  end

  # provide label for type

  def loc_type_label
    LocationCode::LOCATION_CODE_TYPES[ loc_type ] unless loc_type.nil?
  end

  def code_and_label
    code + ' - ' + label
  end

  # set default values according to location type

  def compute_missing_points
    case loc_type
    when 0 # label only, no mileage
      self.center_point = self.start_point = self.end_point = self.length = nil
    when 1 # point only, no start, end, length
      self.start_point = self.end_point = self.length = nil 
    when 2
      #puts "\n>>> old: type #{ self.loc_type }, center: #{ self.center_point }, start: #{ self.start_point }, end: #{ self.end_point }, l: #{ self.length }"
      if self.center_point.nil? then
        if self.length.nil? then
          if self.start_point && self.end_point then
            self.length = self.end_point - self.start_point
            self.center_point = self.start_point + ( self.length / 2 ).to_i
          else # start or end or both are nil
            # nothing to do
          end
        else # length not nil
          if self.start_point.nil? then
            if self.end_point.nil? then
              # nothing to do
            else
              self.start_point = self.end_point - self.length
              self.center_point = self.start_point + ( self.length / 2 ).to_i
            end
          else # start not nil?
            self.end_point = self.end_point || self.start_point + self.length
            self.center_point = self.start_point + ( self.length / 2 ).to_i
          end
        end
      else # center not nil
        if self.length.nil? then
          if self.start_point && self.end_point then
            self.length = self.end_point - self.start_point
          else
            # nothing to do
          end
        else
          self.start_point = self.start_point || ( self.center_point - ( self.length / 2 ).to_i )
          self.end_point = self.end_point || self.start_point + self.length
        end
      end
      #puts ">>> new: type #{ self.loc_type }, center: #{ self.center_point }, start: #{ self.start_point }, end: #{ self.end_point }, l: #{ self.length }"
    end
  end

  # make sure relationship within points makes sense

  def point_relationship
    return if loc_type.nil? || ( loc_type != 2 )
    return if start_point.nil? || end_point.nil?
    # start must be less than end - if specified
    if ( start_point > end_point ) then
      errors.add( :start_point, I18n.t( 'location_codes.msg.bad_start' ))
    # center point must be within start and end point
    # note: I can safely assume that the center was entered or computed
    elsif ( center_point < start_point || center_point > end_point )
      errors.add( :center_point, I18n.t( 'location_codes.msg.bad_center' ))
    end
  end

end