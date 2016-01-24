class HomeController < ApplicationController
  initialize_feature FEATURE_ID_HOME_PAGE, FEATURE_ACCESS_ALL

  # index: initial view, shows homepage for sign-on

  def index
    session[:current_user_id] = nil
  end

  # "create" a signed-on, current user
  # remove leading + trailing blanks, they irritate ...

  def signon
    user = Account.find_by_name( params[ :acc_name ].strip )
    if user && user.authenticate( params[ :password ].strip )
      session[ :current_user_id ] = user.id
      session[ :keep_base_open  ] = user.keep_base_open
      redirect_to base_url
    else
      flash[:alert] = t( 'home.signon.error' )
      redirect_to home_url
    end
  end

  # "delete" a signed-on, current user

  def signoff
    session[ :current_user_id ] = nil
    redirect_to home_url
  end

end
