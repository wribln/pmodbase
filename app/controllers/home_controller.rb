class HomeController < ApplicationController
  initialize_feature FEATURE_ID_HOME_PAGE, FEATURE_ACCESS_ALL + FEATURE_ACCESS_NBP

  # index: initial view, shows homepage for sign-on

  def index
    session[ :current_user_id ] = nil
  end

  # "create" a signed-on, current user
  # remove leading + trailing blanks, they irritate ...

  def signon
    user = Account.find_by_name( params[ :acc_name ].strip )
    if user && user.authenticate( params[ :password ].strip )
      return_to = session[ :return_to ] || base_url
      reset_session
      session[ :current_user_id ] = user.id
      session[ :keep_base_open  ] = user.keep_base_open
      redirect_to return_to
    else
      flash[ :alert ] = t( 'home.signon.error' )
      redirect_to home_url
    end
  end

  # "delete" a signed-on, current user

  def signoff
    delete_user
    redirect_to home_url
  end

end
