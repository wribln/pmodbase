class Permission4Group < ActiveRecord::Base
  include ApplicationModel
  include Filterable
   
  belongs_to :account,  -> { readonly }
  belongs_to :feature,  -> { readonly }, inverse_of: :permission4_groups
  belongs_to :group,    -> { readonly }, optional: true
  
  validates :feature,
    presence: true

  validates :account,
    presence: true
  
  validates :group,
    presence: true, if: Proc.new{ |me| me.group_id != 0 }

  validate :given_group_is_active

  validates :to_index,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :to_create,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :to_read,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :to_update,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :to_delete,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :minimum_permissions
  validate :permission_dependencies

  scope :fr_feature,  -> ( fid ){ where feature_id: fid }
  scope :permission_to_modify, -> { where( '(to_create + to_update + to_delete) > 0' )}
  scope :permission_to_access, -> { where( 'to_index > 0' )}

  # cross-record checks

  # assuming that each permission is >= 0, the sum of them must be > 0
  # or each would be 0 which would be a useless permissions record

  def minimum_permissions
    if( to_index + to_create + to_read + to_update + to_delete )== 0
      errors.add( :base, I18n.t( 'permission4_groups.msg.none_given' ))
    end
  end

  # to_update/to_create requires at least the same access level of to_read
  # otherwise a subsequent show would cause an permission error

  def permission_dependencies
    errors.add( :to_read, I18n.t( 'permission4_groups.msg.insuf_read_lvl' )) \
      if to_read < to_update || to_read < to_create
  end

  # TODO: if would be possible to add additional sanity checks but this could 
  # require information from feature records..., for example:
  #
  # - for certain access levels, no groups should be specified other than 0
  #   (all groups).

  # create label if group_id is zero

  def group_code
    if group_id.present?
      group_id == 0 ? I18n.t( 'permission4_groups.all_groups' ) : group.code_with_id
    end
  end

  def given_group_is_active
    if group_id.present? and group_id != 0 then
      errors.add( :group_id, I18n.t( 'permission4_groups.msg.group_inactive' )) \
        if Group.active_only.find_by_id( group_id ).nil?
    end
  end

end
