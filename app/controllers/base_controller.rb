# This controller displays the main page after a user has signed on.
# It provides links to all available information - mainly tables.
#
# The top bar provides for About, Contact, Logout, Personal Configuration
# and other, general items.

class BaseController < ApplicationController
  initialize_feature FEATURE_ID_BASE_PAGE, FEATURE_ACCESS_USER + FEATURE_ACCESS_NBP

  # present the base page

  def index
    @target = current_user.keep_base_open ? '_blank' : '_self'
    @user_name = current_user.person.user_name 
    @all = BaseItemList.all( current_user )
  end

end
