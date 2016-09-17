require './lib/assets/app_helper.rb'
class LocationCode < ActiveRecord::Base
  include ApplicationModel
  include Filterable
  include LocationCodeHelper

  before_validation :compute_missing_points

  has_many :network_lines
  has_many :network_stops
  has_many :parts_of_relations, class_name: 'LocationCode', foreign_key: 'part_of_id'
  belongs_to :part_of, class_name: 'LocationCode'

  validates :code,
    presence: true,
    uniqueness: true,
    format: { with: Regexp.union( /\A\+!\z/,/\A\+[A-Z0-9.\-]+\z/ ), message: I18n.t( 'location_codes.msg.bad_code_syntax' )},
    length: { maximum: MAX_LENGTH_OF_CODE },
    on: [ :create, :update ] # don't repeat this check for :update_check

  # not needed, test for code prefix is part of code validation: 
  # validate :code_has_prefix

  validates :label,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_LABEL },
    on: [ :create, :update ] # don't repeat this check for :update_check

  # location code types are:
  #
  # 0 - label
  # 1 - point
  # 2 - line (section = 2 points)
  # 3 - building
  # 4 - room
  # 5 - physical area
  # 6 - functional area

  LOCATION_CODE_TYPES = LocationCode.human_attribute_name( :loc_types ).freeze

  validates :loc_type,
    presence: true,
    numericality: { only_integer: true },
    inclusion: { in: 0..( LOCATION_CODE_TYPES.size - 1 )},
    on: [ :create, :update ] # don't repeat this check for :update_check

  validates :center_point, :start_point, :end_point,
    allow_blank: true,
    numericality: :allow_nil,
    on: [ :create, :update ] # don't repeat this check for :update_check

  validate :point_relationship

  validates :length,
    allow_blank: true,
    numericality: { greater_than_or_equal_to: 0.0 },
    on: [ :create, :update ] # don't repeat this check for :update_check

  validates :remarks,
    length: { maximum: MAX_LENGTH_OF_DESCRIPTION },
    on: [ :create, :update ] # don't repeat this check for :update_check

  validates :part_of,
    presence: true, if: Proc.new{ |me| me.part_of_id.present? },
    on: [ :create, :update ] # don't repeat this check for :update_check

  validate :basic_part_checks, on: [ :create, :update ]
  validate :additional_checks, on: :update_check

  set_trimmed :code, :label

  scope :code_order, ->{ order( code: :asc )}
  scope :as_code, -> ( c ){ where( 'code  LIKE ?',  has_code_prefix( c ) ? "#{ c }%" : "#{ code_prefix }#{ c }%" )}
  scope :as_desc, -> ( l ){ where( 'label LIKE :param OR remarks LIKE :param', param: "%#{ l }%" )}
  scope :ff_type, -> ( t ){ where( loc_type: t )}
  scope :ff_part, -> ( p ){ where( part_of_id: p )}
  scope :no_labels, ->{ where.not( loc_type: 0 )}
  scope :part_ofs, ->{ where.not( part_of_id: nil ).distinct }

  # add code_model features

  class << self
    attr_accessor :code_prefix
  end

  @code_prefix = '+'
 
  def self.has_code_prefix( c )
    c && c[ 0 ] == @code_prefix
  end

  # note: use '#{ self.class.table_name }' instead of 'code_modules' if you want
  #       to use table-specific error messages

  # make sure the given code includes the class prefix
  
  def code_has_prefix
    errors.add( :code, I18n.t( 's_code_modules.msg.bad_code_format', prefix: self.class.code_prefix )) \
      unless self.class.has_code_prefix( code )
  end

  # provide label for type

  def loc_type_label
    LocationCode::LOCATION_CODE_TYPES[ loc_type ] unless loc_type.nil?
  end

  # determine location type index from the given string
  # (needed for reading input)

  def self.loc_type_from_label( text )
    LocationCode::LOCATION_CODE_TYPES.index( text )
  end

  def code_and_label
    code + ' - ' + label
  end

  # set default values according to location type

  def compute_missing_points
    case loc_type
    when 0, 3..6 # no mileage
      self.center_point = self.start_point = self.end_point = self.length = self.part_of_id = nil
    when 1 # point only, no start, end, length
      self.start_point = self.end_point = self.length = nil 
    when 2
      if self.center_point.nil? then
        if self.length.nil? then
          if self.start_point && self.end_point then
            self.length = self.end_point - self.start_point
            self.center_point = self.start_point + ( self.length / 2 )
          else # start or end or both are nil
            # nothing I can do
          end
        else # length not nil
          if self.start_point.nil? then
            if self.end_point.nil? then
              # nothing I can do
            else
              self.start_point = self.end_point - self.length
              self.center_point = self.start_point + ( self.length / 2 )
            end
          else # start not nil?
            if self.end_point.nil? then
              self.end_point = self.start_point + self.length
              l = self.length
            else
              l = self.end_point - self.start_point
            end
            self.center_point = self.start_point + ( l / 2 )
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
          self.start_point = self.start_point || ( self.center_point - ( self.length / 2 ))
          self.end_point = self.end_point || self.start_point + self.length
        end
      end
    end
  end

  # make sure relationship among points make sense

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

  # basic checks on the part_of attribute

  def basic_part_checks
    unless part_of_id.blank? || errors.include?( :part_of_id ) then
      errors.add( :part_of_id, I18n.t( 'location_codes.msg.bad_part_of' )) \
        unless part_of_id != id 
    end
  end

  # extra validations for part_of - do only if requested
  # these validations should produce rather warnings that something
  # could be wrong with this records...

  def additional_checks
    if loc_type == 2 && start_point && end_point && center_point then
      unless ( end_point - start_point - length ).abs < 1 then
        errors.add( :base, I18n.t( 'location_codes.msg.bad_line1' ))
        return
      end
      unless ( start_point + ( length / 2.0 ) - center_point ).abs < 1 then
        errors.add( :base, I18n.t( 'location_codes.msg.bad_line2' ))
        return
      end
    end
    unless part_of.blank? || errors.include?( :part_of_id ) then
      unless permitted_combination( loc_type, part_of.loc_type ) then
        errors.add( :base, I18n.t( 'location_codes.msg.bad_combo', p1: loc_type_label, p2: part_of.loc_type_label ))
        return
      end
      if part_of.loc_type == 2 && part_of.start_point && part_of.end_point then # check for boundaries
        if loc_type == 1 then
          check_range( center_point )
        elsif loc_type == 2 then
          check_range( center_point )
          check_range( start_point )
          check_range( end_point )
        end
      end
    end
  end

  private

    PERMITTED_COMBINATIONS = [
      [],         # label must not be part of anything else
      [ 2 ],      # point can be part of line section
      [ 2 ],      # line section can be part of another line section
      [ 5 ],      # building can be part of a physical area
      [ 3, 5 ],   # room can be part of a building or a functional area
      [ 3, 4, 5, 6 ], # functional areas can be part of almost anything
      [ 3, 4, 5, 6 ]  # physical areas can be part of almost anything
    ]

    def permitted_combination( c, p )
      PERMITTED_COMBINATIONS[ c ].include?( p )
    end

    def check_range( value )
      return if value.nil?
      unless ( value >= part_of.start_point && value <= part_of.end_point )
        errors.add( :base, I18n.t( 'location_codes.msg.bad_range', 
          p1: db_formatted_km( value ), 
          p2: db_formatted_km( part_of.start_point ),
          p3: db_formatted_km( part_of.end_point )))
      end
    end
    
end
