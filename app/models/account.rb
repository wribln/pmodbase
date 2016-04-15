class Account < ActiveRecord::Base
  include ApplicationModel
  include Filterable
  include PersonCheck
  
  belongs_to :person, -> { readonly }, inverse_of: :accounts
  has_many :requesting_account, class_name: 'DbChangeRequest'
  has_many :responsible_account, class_name: 'DbChangeRequest'
  has_many :permission4_groups, inverse_of: :account
  has_many :permission4_flows, inverse_of: :account
  has_many :rfc_documents, inverse_of: :account
  has_many :tia_lists, inverse_of: :account
  has_many :tia_items, inverse_of: :account
  has_many :tia_members, inverse_of: :account
  has_many :dsr_doc_groups, inverse_of: :account
  accepts_nested_attributes_for :permission4_groups, allow_destroy: true, reject_if: :ignore_permission
  accepts_nested_attributes_for :permission4_flows, allow_destroy: true
  validates_associated :permission4_groups
  validates_associated :permission4_flows
  has_secure_password

  validates :name,
    length: { maximum: MAX_LENGTH_OF_ACCOUNT_NAME },
    presence: true,
    uniqueness: true,
    format:  { with: /\A\w{3}\w*\z/, message: I18n.t( 'accounts.msg.bad_syntax' )}
    
  validates :password,
    presence: true,
    confirmation: true,
    format: { with: /\A.*(?=.{8,})(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[\W_]).*\z/x,
      message: I18n.t( 'accounts.msg.bad_syntax' )},
    length: { maximum: MAX_LENGTH_OF_PASSWORD },
    if: lambda { |user| new_record? || !user.password.to_s.empty? }

  validates :person_id,
    presence: true

  validate :given_person_exists

  scope :ff_id,         -> ( id         ){ where id: id }
  scope :ff_name,       -> ( name       ){ where( 'name LIKE ?', "%#{ name }%" )}
  scope :ff_person_id,  -> ( person_id  ){ where person_id: person_id }
  scope :ff_active,     -> ( active     ){ where active: ( active == '1' )}
  scope :is_active, ->{ where active: true }

  # function which determines whether a permission should be added

  def ignore_permission( attributes )
    attributes[ :feature_id ].nil? || attributes[ :group_id ].nil?
  end

  # check if account has any access to a specific feature

  def permission_to_index?( feature )
    if active
      if feature.kind_of? Integer
        permission4_groups.where( feature: feature ).sum( :to_index ) > 0
      else # assume string 
        permission4_groups.joins( :feature ).where( feature:{ name: feature.to_s }).sum( :to_index ) > 0
      end
    else
      false
    end
  end

  # Prepare the SQL clause for testing which groups can be accessed by this account.
  # Essentially, this method provides the information "Which groups have the specified
  # access right for the given feature". The result can be used in a where clause,
  # either in the Group model (to list all groups for which this account allows this
  # access), or to check if a record with a certain group reference (check_var) is
  # accessible for the given action by this account.
  # 
  # [feature]   must be the feature_id to be tested for
  # [action]    must be one of the Permission4Group fields corresponding to the
  #             respective action_names (as symbol): :to_index, :to_create, :to_read,
  #             :to_update, :to_delete
  # [check_var] must correspond to the table column to which the where clause shall
  #             apply to. This is often the group_id column containing the group
  #             association; if the clause is used on the Groups table, check_var
  #             must be set to :id.
  # [check_val] is the value to test against; if not given, any value greater than 
  #             zero will pass the test.
  #
  # Please note that this code is written to easily understand the checks.

  def permitted_groups( feature, action = :to_index, check_var = :group_id, check_val = nil )
    if active
      if $DEBUG then
        raise ArgumentError.new( "invalid action: #{ action }" ) \
          unless [ :to_index, :to_create, :to_read, :to_update, :to_delete ].include? action
        raise ArgumentError.new( "invalid id: #{ check_var } - must be a symbol") \
          unless check_var.kind_of? Symbol
      end
      p = permission4_groups.where( feature: feature ).where( check_val.nil? ? "#{action} > 0" : "#{action} = #{check_val}" ).order( :group_id )
      if p.empty?
        return nil # none
      else
        if p[ 0 ][ :group_id ] == 0
          return "" # all
        else
          return "#{ check_var } IN (#{ p.collect{ |pp| pp[ :group_id ] }.join(',')})"
          # -> where check_var IN (id1,id2,...,idn)
        end
      end
    else
      return nil # none
    end
  end

  # returns a clause suitable to select a subset of the feature list

  def permitted_features( to_modify = true, check_var = :id )
    p = to_modify ? permission4_groups.permission_to_modify : permission4_groups.permission_to_access?
    if p.empty? then
      return nil # none
    else
      return "#{ check_var } IN (#{ p.collect{ |pp| pp[ :feature_id ] }.join(',')})"
    end
  end

  # check if account has access to a specific record:
  # - use this before accessing a specific record for CRUD actions
  # - use group = nil if groups are not used for this feature
  # returns false only when no access allowed, else returns the
  # access level for this feature and group

  def permission_to_access( feature, action, group = nil )
    if active
      if group.nil? || group.zero?
        max_permission = permission4_groups.where( feature: feature ).maximum( action )
      else
        max_permission = permission4_groups.where( feature: feature ).where({ group: [ 0, group ]}).maximum( action )
      end
      return max_permission.nil? || max_permission.zero? ? false : max_permission
    else
      return false
    end end

  # check if account has permission for a specific task in the given workflow

  def permission_for_task?( feature, workflow, task )
    if active
      p = permission4_flows.where( feature: feature, workflow_id: workflow)
      p.empty? ? false : p[ 0 ].permission_for_task?( task )
    end
  end

  # return those workflows to which the current user has creation access to

  def permitted_workflows( feature )
    if active
      p = permission4_flows.where( feature: feature )
      if p.empty?
        return nil # none
      else
        p.collect do |p4f|
          p4f.workflow_id if p4f.permission_for_creation?
        end.compact
      end
    end
  end
  
  # show account name with id

  def name_with_id
    text_and_id( :name )
  end

  # show user's name

  def user_name
    person.try( :user_name )
  end

  def self.user_name( id )
    Account.find( id ).user_name unless id.nil?
  end

  # provide statistics (must use self. here to override super.method)

  def self.get_stats
    super << [ 'inactive', Account.where( active: false ).count ]
  end

end
