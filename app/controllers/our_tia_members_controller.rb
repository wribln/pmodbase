class OurTiaMembersController < ApplicationController
  initialize_feature FEATURE_ID_OUR_TIA_MEMBERS, FEATURE_ACCESS_USER + FEATURE_ACCESS_NDA, FEATURE_CONTROL_CUG
  before_action :set_tia_list,   only: [ :index, :create, :new ]
  before_action :set_tia_member, only: [ :show, :edit, :update, :destroy]
  before_action :set_breadcrumb

  # GET /mtls/1/otms

  def index
    set_breadcrumb_path( my_tia_list_our_tia_members_path( params[ :my_tia_list_id ]))
    @tia_members = @tia_list.tia_members
  end

  # GET /otms/1

  def show
    set_breadcrumb_path( my_tia_list_our_tia_members_path( @tia_member.tia_list ))
  end

  # GET /mtls/1/new

  def new
    set_breadcrumb_path( my_tia_list_our_tia_members_path( params[ :my_tia_list_id ]))
    @tia_member = @tia_list.tia_members.new
  end

  # GET /otms/1/edit

  def edit
    set_breadcrumb_path( my_tia_list_our_tia_members_path( @tia_member.tia_list ))
  end

  # POST /tia_members

  def create
    @tia_member = @tia_list.tia_members.new( tia_member_params )
    respond_to do |format|
      if @tia_member.save
        format.html { redirect_to our_tia_member_path( @tia_member ), notice: t( 'our_tia_members.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /tia_members/1

  def update
    respond_to do |format|
      if @tia_member.update(tia_member_params)
        format.html { redirect_to our_tia_member_path, notice: t( 'our_tia_members.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /tia_members/1

  def destroy
    @tia_member.destroy
    respond_to do |format|
      format.html { redirect_to my_tia_list_our_tia_members_path( @tia_list ), notice: t( 'our_tia_members.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    # set the @tia_list (non-existing will cause exception/404 error) and check
    # if current user has permission to access this list and its items

    def set_tia_list
      @tia_list = TiaList.find( params[ :my_tia_list_id ])
      # permit access if current user is either owner or deputy of this list
      render_no_access unless true #@tia_list.user_is_owner_or_deputy?( current_user.id )
    end

    def set_tia_member
      @tia_member = TiaMember.find( params[ :id ])
      @tia_list = @tia_member.tia_list
      render_no_access unless true
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def tia_member_params
      params.require( :tia_member ).permit( :tia_list_id, :account_id, :to_access, :to_update )
    end

    def set_breadcrumb
      parent_breadcrumb( :my_tia_lists, my_tia_lists_path )
    end
end
