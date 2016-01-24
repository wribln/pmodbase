require './lib/assets/app_helper.rb'
class Feature < ActiveRecord::Base
  include ApplicationModel
  include FeatureCategoryCheck
  
  belongs_to :feature_category, -> { readonly }, inverse_of: :features
  has_many   :permission4_groups, -> { readonly }, inverse_of: :features
  has_many   :permission4_flows, -> { readonly }, inverse_of: :features

  validates :code,
    length: { maximum: MAX_LENGTH_OF_CODE },
    presence: true,
    uniqueness: true,
    format: { with: /\A\w+\z/, message: I18n.t( 'features.msg.bad_code' )}

  validate :code_has_route

  validates :feature_category_id,
    presence: true

  validate :given_feature_category_exists

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

  validates :control_level,
    presence: true,
    numericality: { only_integer: true },
    inclusion: { in: 0..4 }

  FEATURE_CONTROL_LEVELS = Feature.human_attribute_name( :control_levels ).freeze

  # no_workflows must correspond to application controller's no_workflows

  validates :no_workflows,
    presence: true,
    numericality: { only_integer: true }

  # scope for features with workflows

  scope :with_wf, -> { where( 'no_workflows > 0' )}

  # make sure a route exists for this code - unless this feature is hidden;

  def code_has_route
    route = "/#{ code.downcase.pluralize }"
    Rails.application.routes.recognize_path( route ) \
      unless no_user_access? || no_direct_access?
    rescue
      errors.add( :base, "missing route: /#{ route }")
  end

  # overwrite write accessors to ensure that text fields do not contain
  # any redundant blanks

  def code=( text )
    write_attribute( :code, AppHelper.clean_up( text, MAX_LENGTH_OF_CODE ))
  end

  def label=( text )
    write_attribute( :label, AppHelper.clean_up( text, MAX_LENGTH_OF_LABEL ))
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
    FEATURE_ACCESS_LEVELS[ access_level & 0x0F ]
  end

  def control_level_label
    FEATURE_CONTROL_LEVELS[ control_level ]
  end    
  
end
