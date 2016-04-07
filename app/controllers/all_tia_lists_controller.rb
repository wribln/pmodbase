# administrative controller for all TIA lists
# for individual TIA lists, see MyTiaListsController

class AllTiaListsController < ApplicationController
  initialize_feature FEATURE_ID_ALL_TIA_LISTS, FEATURE_ACCESS_SOME
  before_action :set_tia_list,  only: [ :show, :edit, :update, :destroy ]
  before_action :set_tia_lists, only: [ :index ]

  # GET /all_tia_lists

  def index
  end

  # GET /all_tia_lists/1
 
  def show
  end

  # GET /all_tia_lists/new

  def new
    @tia_list = TiaList.new
  end

  # GET /all_tia_lists/1/edit

  def edit
  end

  # POST /all_tia_lists

  def create
    @tia_list = TiaList.new( tia_list_params )
    respond_to do |format|
      if @tia_list.save
        format.html { redirect_to all_tia_list_url( @tia_list ), notice: t( 'tia_lists.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /all_tia_lists/1

  def update
    respond_to do |format|
      params[ :tia_list ][ :tia_members_attributes ].try( :delete, 'template' )
      @tia_list.assign_attributes( tia_list_params ) unless tia_list_params.empty?
      #if @tia_list.update( tia_list_params )
      if @tia_list.save
        format.html { redirect_to all_tia_list_url( @tia_list ), notice: t( 'tia_lists.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /all_tia_lists/1

  def destroy
    @tia_list.destroy
    respond_to do |format|
      format.html { redirect_to all_tia_lists_url, notice: t( 'tia_lists.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_tia_lists
      @tia_lists = TiaList.all
    end

    def set_tia_list
      @tia_list = TiaList.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def tia_list_params
      params.require( :tia_list ).permit(
        :code, :label, :owner_account_id, :deputy_account_id,
        tia_members_attributes: 
          [ :id, :_destroy, :account_id, :to_access, :to_update ])
    end

end
