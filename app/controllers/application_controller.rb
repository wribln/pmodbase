class ApplicationController < ActionController::Base
  include BreadcrumbList
  before_action :check_permission_to_access 

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  
  protect_from_forgery with: :exception

  # Define a class attribute holding the feature id and make it available
  # in the views (per helper_method)

  class_attribute :feature_identifier, instance_writer: false
  helper_method   :feature_identifier

  # Define the feature access level as class attribute, some values are
  # designed to support bitmap handling

  class_attribute :feature_access_level, instance_writer: false

  # make sure respective labels exists for .feature.access_levels
  # binary/octal: 000000/00 - no access
  #               xxxxx1/01 - require specific permission
  #               xxxx1x/02 - access index permitted
  #               xxx1xx/04 - access read permitted
  #               xx1xxx/08 - access created/update/delete
  #               x1xxxx/10 - no restrictions
  #               1xxxxx/20 - hidden feature (no access from base page)

  FEATURE_ACCESS_NONE =   0x00   # no access at all / feature disabled
  FEATURE_ACCESS_SOME =   0x01   # user must have specific permission
  FEATURE_ACCESS_INDEX =  0x02   # user must exist to access index
  FEATURE_ACCESS_READ =   0x04   # user must exist to access details
  FEATURE_ACCESS_VIEW =   0x06   # user must exist to access index and details
  FEATURE_ACCESS_USER =   0x0E   # user must exist to access feature
  FEATURE_ACCESS_ALL =    0x10   # no access restrictions
  FEATURE_ACCESS_NBP =    0x20   # hidden feature, not access from base page
  FEATURE_ACCESS_MAX =    0x3E   # maximum value for validations

  # Define a feature control level that documents which controls
  # are implemented in addition to the feature access levels:

  class_attribute :feature_control_level, instance_writer: false

  # make sure respective labels exists for .feature.control_levels

  FEATURE_CONTROL_NONE =  0   # no further controls
  FEATURE_CONTROL_GRP =   1   # access control on group level
  FEATURE_CONTROL_WF =    2   # access control on workflow level
  FEATURE_CONTROL_GRPWF = 3   # access control on group and workflow level
  FEATURE_CONTROL_CUG =   4   # access for closed user group
  FEATURE_CONTROL_CUGRP = 5   # access control on group level + closed users group

  # Provide an attribute which tells us how many workflows are implemented
  # by this controller (used by FeaturesController, AccountsController )

  class_attribute :no_workflows, instance_writer: false

  # The following structure maps controller methods to respective
  # permission fields

  ACTION_PERMISSION_MAP = {
    'index'   => :to_index,
    'info'    => :to_index,
    'stats'   => :to_index,
    'new'     => :to_create,
    'add'     => :to_create,
    'create'  => :to_create,
    'update'  => :to_update,
    'destroy' => :to_delete,
    'show'    => :to_read,
    'edit'    => :to_update
  }
  private_constant :ACTION_PERMISSION_MAP

  # this makes it easier to determine the default helpfile

  class_attribute :feature_help_file
  helper_method :feature_help_file

  protected

  # use a protected method to initialize feature

  def self.initialize_feature( id, fal = FEATURE_ACCESS_NONE, fcl = FEATURE_CONTROL_NONE, nwf = 0 )
    self.feature_identifier = id
    self.feature_access_level = fal
    self.feature_control_level = fcl
    self.no_workflows = nwf
    self.feature_help_file = controller_name
  end

  # wrap ACTION_PERMISSION_MAP to a method in order to be more 
  # flexibel regarding action names: only the part of the action_name
  # up to the first none alphabetic character will be considered

  def map_action_to_permission
    ACTION_PERMISSION_MAP[ action_name ] || 
    ACTION_PERMISSION_MAP[ action_name[/[a-z]+/]]
  end

  # this will check the accessability of the feature according to the 
  # access level

  def check_permission_to_access

    # no feature_access_level or level none:

    if ApplicationController.no_user_access?( self.feature_access_level )
      session[ :return_to ] = nil
      render_no_access
      return
    end

    # early exit if no access restrictions

    return if ( self.feature_access_level & FEATURE_ACCESS_ALL != 0 )
       
    # for the next levels, we need an existing user:
    # in case of time-out, allow user to return here

    if current_user.nil?
      session[ :return_to ] = request.url
      render_no_access
      return
    end

    # map_action_to_permission only once:

    permission_needed = map_action_to_permission

    # check if user needs access to index only

    return if( self.feature_access_level & FEATURE_ACCESS_INDEX != 0 )and
      permission_needed == :to_index

    # read access for all?

    return if( self.feature_access_level & FEATURE_ACCESS_READ != 0 )and
      permission_needed == :to_read

    # check for general access permission

    return if( self.feature_access_level & FEATURE_ACCESS_USER )== FEATURE_ACCESS_USER

    # finally, check if user has specific permissions

    return if current_user.permission_to_access( self.feature_identifier, permission_needed )

    # otherwise, allow user to request access

    request_change

  end

  # check if user has permission to access group as given by group_id
  # if group_id is nil - which should never occur - the method will return false as well
  # since group_id must not be null (see schema)

  def has_group_access?( group_id )
    unless current_user.permission_to_access( self.feature_identifier, map_action_to_permission, group_id )
      request_change
      false
    else
      true
    end
  end

  # Do we need to check for group-specific permissions?

  def self.access_by_group?( level )
    level && ( level & FEATURE_CONTROL_GRP ) != 0
  end

  # Does the given level allow access to the index? Make it a little bit safer
  # by checking for nil (which should not be necessary)

  def self.access_to_index?( level )
    level && ( level & ( FEATURE_ACCESS_INDEX | FEATURE_ACCESS_READ | FEATURE_ACCESS_ALL ) != 0 )
  end

  def self.access_to_view?( level )
    level && ( level & ( FEATURE_ACCESS_READ | FEATURE_ACCESS_ALL ) != 0 )
  end

  # Does the given level allows no access at all?

  def self.no_user_access?( level )
    level.nil? || level == FEATURE_ACCESS_NONE
  end

  def self.no_direct_access?( level )
    level.nil? || ( level == FEATURE_ACCESS_NONE ) || ( level & FEATURE_ACCESS_NBP ) != 0
  end

  private

  # Find the user/account with the ID store in the session with the key
  # :current_user_id. This is the common way to handle user login in a Rails
  # application; sign-on sets the session value, and sign-off removes it
  # (this is done here by the home_controller).

  def current_user
    @_current_user ||=  session[ :current_user_id ] &&
    Account.find_by_id( session[ :current_user_id ])
  end

  # mostly for testing, I needed a method which allows me to clear the current
  # user in the system; now I am using it for the home page as well when
  # signing off

  def delete_user
    @_current_user = session[ :current_user_id ] = nil
    reset_session
  end
  public :delete_user

  # Request_change creates a user-specific change request if she clicks on a
  # link but does not have the permission to use the action on that feature.

  def request_change
    @dbcr = DbChangeRequest.new
    @dbcr.requesting_account_id = current_user.id
    @dbcr.feature_id = self.feature_identifier
    @dbcr.detail = params[ :id ]
    @dbcr.action = action_name
    @dbcr.uri = request.fullpath
    flash.now[ :notice ] = t( map_action_to_permission, scope: 'my_change_requests.new.flash' )
    render 'my_change_requests/new', status: :unauthorized
  end

  # This is a general handler for all unauthorized/invalid access attempts
  #
  # 401 - user has no authorization to access this action
  # 403 - user has no permission for this action

  def render_no_access
    render file: 'public/401.html', status: :unauthorized
  end

  def render_no_permission
    render file: 'public/403.html', status: :forbidden
  end

  def render_no_resource
    render file: 'public/404.html', status: :not_found
  end

  # output message with details why this is not allowed;
  # the status code 422 seems to be appropriate

  def render_bad_logic( msg )
    @details = msg
    render file: 'public/422.html.erb', status: :unprocessable_entity
  end

end
