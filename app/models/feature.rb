require './lib/assets/app_helper.rb'
class Feature < ActiveRecord::Base
  include ApplicationModel
  include ActiveModelErrorsAdd
  
  belongs_to :feature_category, -> { readonly }, inverse_of: :features
  has_many   :permission4_groups, -> { readonly }, inverse_of: :features
  has_many   :permission4_flows, -> { readonly }, inverse_of: :features

  validates :code,
    length: { maximum: MAX_LENGTH_OF_CODE },
    presence: true,
    uniqueness: true,
    format: { with: /\A\w+\z/, message: I18n.t( 'features.msg.bad_code' )}

  validates :feature_category,
    presence: true

  validates :label,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  validates :seqno,
    presence: true,
    numericality: { only_integer: true }

  # access_level must correspond to application controllers feature_access_level

  validates :access_level,
    presence: true,
    numericality: { only_integer: true },
    inclusion: { in: 0..ApplicationController::FEATURE_ACCESS_MAX }

  FEATURE_ACCESS_LEVELS = Feature.human_attribute_name( :access_levels ).freeze

  # control_level must correspond to application controller's feature_control_level

  FEATURE_CONTROL_LEVELS = Feature.human_attribute_name( :control_levels ).freeze

  validates :control_level,
    presence: true,
    numericality: { only_integer: true },
    inclusion: { in: 0..( FEATURE_CONTROL_LEVELS.size - 1 )}

  # no_workflows must correspond to application controller's no_workflows

  validates :no_workflows,
    presence: true,
    numericality: { only_integer: true }

  # scope for features with workflows

  scope :with_wf, -> { where( 'no_workflows > 0' )}
  scope :all_by_label, -> { order( label: :asc )}

  # permitted_features: scope helper in conjunction with Account.permitted_features
  # to provide the scope for features to which a user has access to: This will
  # return then all Feature records to which the given account is permitted
  # access to according to the conditions specified in the Account.permitted_features
  # method

  def self.permitted_features( pf )
    case pf
    when nil
      none
    when ''
      all
    else
      where pf
    end
  end

  # provide helper methods which create a route

  def self.create_target( a_code )
    "/#{ a_code.downcase }"
  end    

  def create_target
    self.class.create_target( code )
  end

  # overwrite write accessors to ensure that text fields do not contain
  # any redundant blanks

  def code=( text )
    write_attribute( :code, AppHelper.clean_up( text ))
  end

  def label=( text )
    write_attribute( :label, AppHelper.clean_up( text ))
  end

  # provide labels with id suffix

  def label_with_id
    text_and_id( :label )
  end

  def feature_category_with_id
    assoc_text_and_id( :feature_category, :label )
  end

  # provide application controller methods for instances of this class

  def access_to_index?
    ApplicationController::access_to_index?( access_level )
  end

  def access_to_view?
    ApplicationController::access_to_view?( access_level )
  end

  def no_user_access?
    ApplicationController::no_user_access?( access_level )
  end

  def access_by_group?
    ApplicationController::access_by_group?( control_level )
  end

  def no_direct_access?
    ApplicationController::no_direct_access?( access_level )
  end

  # make labels for user access available

  def access_level_label
    case access_level
    when ApplicationController::FEATURE_ACCESS_NONE, ApplicationController::FEATURE_ACCESS_NBP
       FEATURE_ACCESS_LEVELS[ 0 ]
    when ApplicationController::FEATURE_ACCESS_SOME
       FEATURE_ACCESS_LEVELS[ 1 ]
    when ApplicationController::FEATURE_ACCESS_INDEX
       FEATURE_ACCESS_LEVELS[ 2 ]
    when ApplicationController::FEATURE_ACCESS_VIEW 
       FEATURE_ACCESS_LEVELS[ 3 ]
    when ApplicationController::FEATURE_ACCESS_USER 
       FEATURE_ACCESS_LEVELS[ 4 ]
    when ApplicationController::FEATURE_ACCESS_ALL
       FEATURE_ACCESS_LEVELS[ 5 ]
    else
      access_level.to_s( 16 )
    end
  end

  def control_level_label
    FEATURE_CONTROL_LEVELS[ control_level ]
  end    
  
end
