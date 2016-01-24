class ProfilesController < ApplicationController
  initialize_feature FEATURE_ID_PROFILE, FEATURE_ACCESS_USER
  before_action :set_profile, only: [ :show, :edit, :update ]
  before_action :set_address_options, only: [ :edit, :update ]

  # GET /profile

  def show
  end

  # GET /profile/edit
  
  def edit
  end

  # PATCH/PUT /profile
  
  def update
    respond_to do |format|
      if @person.update( profile_params )
        format.html { redirect_to profile_path, notice: t( 'profiles.notice.update_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_profile
      if current_user.nil?
        redirect_to :home, notice: t( 'profiles.notice.pls_signon') 
      else
        @person = Person.find( current_user.person_id )
        @user_id = current_user.id
        set_final_breadcrumb( action_name )
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def profile_params
      params.require(:person).permit( :id, :formal_name, :informal_name, :email,
        accounts_attributes: [ :id, :name, :password, :password_confirmation, :keep_base_open ],
        contact_infos_attributes: [ :id, :info_type, :phone_no_fixed, :phone_no_mobile, :department, :detail_location, :address_id ])
    end

    def set_address_options
       @address_options = Address.all.map{ |a| [ a.label, a.id ]}
    end
    
end
