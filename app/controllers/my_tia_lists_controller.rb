# controller for TIA lists of calling user
# for administration of all TIA lists, see AllTiaListsController

class MyTiaListsController < ApplicationController
  initialize_feature FEATURE_ID_MY_TIA_LISTS, FEATURE_ACCESS_SOME, FEATURE_CONTROL_CUG
  before_action :set_tia_list,  only: [ :show, :edit, :update, :destroy ]
  before_action :set_tia_lists, only: [ :index ]

  # GET /my_tia_lists

  def index
  end

  # GET /my_tia_lists/1
 
  def show
  end

  # GET /my_tia_lists/new

  def new
    @tia_list = TiaList.new
    @tia_list.owner_account_id = current_user.id
  end

  # GET /my_tia_lists/1/edit

  def edit
  end

  # POST /my_tia_lists

  def create
    @tia_list = TiaList.new( tia_list_params )
    respond_to do |format|
      if user_is_owner_or_deputy? && @tia_list.save then
        format.html { redirect_to my_tia_list_url( @tia_list ), notice: t( 'my_tia_lists.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /my_tia_lists/1

  def update
    respond_to do |format|
      @tia_list.assign_attributes( tia_list_params ) unless tia_list_params.empty?
      if user_is_owner_or_deputy? && @tia_list.save then
        format.html { redirect_to my_tia_list_url( @tia_list ), notice: t( 'my_tia_lists.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /my_tia_lists/1

  def destroy
    @tia_list.destroy
    respond_to do |format|
      format.html { redirect_to my_tia_lists_url, notice: t( 'my_tia_lists.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_tia_lists
      @tia_lists = TiaList.for_user( current_user.id )
    end

    def set_tia_list
      @tia_list = TiaList.for_user( current_user.id ).find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def tia_list_params
      params.require( :tia_list ).permit( :code, :label, :owner_account_id, :deputy_account_id, :members )
    end

    # make sure current user is either owner or deputy

    def user_is_owner_or_deputy?
      if @tia_list.user_is_owner_or_deputy?( current_user.id ) then
        true
      else
        @tia_list.errors.add( :base, I18n.t( 'my_tia_lists.msg.invalid_account', id: current_user.id ))
        false
      end
    end

end
