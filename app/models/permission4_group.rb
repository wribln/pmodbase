class Permission4Group < ActiveRecord::Base
  include ApplicationModel
  include AccountCheck
  include FeatureCheck
  include GroupCheck
  include Filterable
   
  belongs_to :account,  -> { readonly }, inverse_of: :permission4_groups
  belongs_to :feature,  -> { readonly }, inverse_of: :permission4_groups
  belongs_to :group,    -> { readonly }, inverse_of: :permission4_groups
  
  validates :feature_id,
    presence: true

  validate :given_feature_exists

  # the following validations should not be necessary as a permission
  # is always created with an account - however, it is included to
  # ensure database consistency at minimal cost (check occurs only
  # when permission record is modified)

  validates :account_id,
    presence: true
  
  validate :given_account_exists

  validates :group_id,
    numericality: { only_integer: true, greater_than_or_equal_to: 0, message: I18n.t( 'permission4_groups.msg.bad_group_id' )}

  validate :given_group_exists_or_is_zero

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

  # to_update requires at least the same access level of to_read

  def permission_dependencies
    if( to_read < to_update )
      errors.add( :base, I18n.t( 'permission4_groups.msg.upd_req_read' ))
    end
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

end
