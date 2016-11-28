require './lib/assets/app_helper.rb'
class Group < ActiveRecord::Base
  include ApplicationModel
  include ActiveModelErrorsAdd
  include Filterable
  
  belongs_to  :group_category, -> { readonly }, inverse_of: :groups
  has_many    :responsibilities
  has_many    :permission4_groups
  has_many    :pcp_categories
  has_many    :pcp_subjects
  has_many    :cfr_records
  has_many    :sub_groups,   class_name: 'Group', foreign_key: 'sub_group_of_id'
  belongs_to  :sub_group_of, class_name: 'Group'

  before_destroy :check_destroyable

  validates :code,
    uniqueness: true,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_CODE }

  validates :group_category,
    presence: true

  validates :label,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  validates :notes,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  validates :seqno,
    presence: true,
    numericality: { only_integer: true }

  validate :sub_group_reference
  validate :inactive_group_not_used

  set_trimmed :code, :label, :notes

  default_scope { order( code: :asc )}
  scope :participants_only, -> { where( participating: true)}
  scope :active_only, ->    { where( active: true )}
  scope :sender_codes, ->   { where( s_sender_code: true )}
  scope :receiver_codes, -> { where( s_receiver_code: true )}
  scope :as_abbr, -> ( a ){ where( 'code LIKE ?',   "#{ a }%" )}
  scope :as_desc, -> ( d ){ where( 'label LIKE ?', "%#{ d }%" )}
  class << self; alias :as_code :as_abbr end

  # permitted_groups: scope helper in conjunction with Account.permitted_groups
  # to provide the scope for groups to which user has access to: This will
  # return then all Group records to which the given account is permitted
  # access to according to the conditions specified in the Account.permitted_groups
  # method

  def self.permitted_groups( pg )
    case pg
    when nil
      none
    when ''
      all
    else
      where( id: pg )
    end
  end

  def label_with_id
    text_and_id( :label )
  end

  def code_with_id
   text_and_id( :code )    
  end

  # ensure that the referenced subgroup is valid:
  # 1. must not reference itself
  # 2. must be an existing group
  # 3. references must be hierarchical, no cycles allowed

  def sub_group_reference
    unless sub_group_of_id.nil?
      if sub_group_of_id == id
        errors.add( :sub_group_of_id, I18n.t( 'groups.msg.bad_sub_ref' ))
      elsif !Group.exists?( sub_group_of_id )
        errors.add( :sub_group_of_id, I18n.t( 'groups.msg.bad_sub_group' ))
      elsif Group.descendant_groups.empty?
        errors.add( :base, I18n.t( 'group.msg.bad_hierarchy' ))
      end
    end
  end

  # make sure that no user has specific permissions for this group when
  # this group is deactivated / not active

  def inactive_group_not_used
    if !self.active then
      errors.add( :base, I18n.t( 'groups.msg.no_deactivate')) \
        unless self.permission4_groups.empty?
    end
  end

  # return here true only if this group is not used anymore by anyone.
  # Since you should not remove any groups at any time, this is just 
  # for my own sanity...

  def check_destroyable
    if self.responsibilities.empty? &&
       self.permission4_groups.empty? &&
       self.sub_groups.empty? &&
       self.cfr_records.empty? then
      true
    else
      errors.add( :base, I18n.t( 'groups.msg.in_use' ))
      false
    end
  end

  # helper function for descendant_groups:
  # used recursively to traverse all sub_groups

  private_class_method def self.collect_descendants( b, c, r, i )
    if c[ i ].nil? # node not yet visited
      c[ i ] = [ i ]
      b[ i ].each{| j | collect_descendants( b, c, i, j )}
    end
    return if r == i # we are done for this node
    if( c[ r ] & c[ i ]).empty?
      c[ r ].concat( c[ i ])
    else
      raise ArgumentError, "cycle detected while adding #{ i }"
    end
  end

  # create a hash containing all sub-groups of each group
  # return nil if group structure is not hierarchical

  def self.descendant_groups

    # retrieve all relationships

    a = self.pluck( :id, :sub_group_of_id )

    # create hash of direct descendants

    b = Hash.new
    a.each {| x | b[ x.first ] = Array.new unless x.first.nil? }
    a.each do | x |
      next if x.last.nil? # ignore nodes w/o parent
      return nil if b[ x.last ].nil?  # reference to non-existing node - should not occur
      return nil if x.first == x.last # reference to itself - should not occur
      b[ x.last ].push( x.first )
    end

    c = Hash.new
    begin
      b.each_key{| x | collect_descendants( b, c, x, x )}
    rescue ArgumentError
      c.clear
    end
    return c

  end

end
