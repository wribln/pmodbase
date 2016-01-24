# controller for TIA items of calling user

class MyTiaItemsController < ApplicationController
  initialize_feature FEATURE_ID_MY_TIA_ITEMS, FEATURE_ACCESS_INDEX, FEATURE_CONTROL_CUG
  before_action :set_tia_item, only: [ :show, :info, :edit, :update ]

  # get /tia_items

  def index
    @tia_items = TiaItem.active.where( current_user.id ).order( :tia_list_id )
  end

  def show
    render_no_permission unless @tia_list.permitted_to_access?( current_user.id )
  end

  def info
    if @tia_list.permitted_to_access?( current_user.id ) then
      set_final_breadcrumb( :history )
      render 'our_tia_items/info'
    else
      render_no_permission
    end
  end

  def edit
    render_no_permission unless @tia_list.permitted_to_update?( current_user.id )
  end

  # NOTE: this piece of code must be (almost) identical to the corresponding one in
  # OurTiaItemsController: If you change something here, make sure you do it there.

  def update
    if @tia_list.permitted_to_update?( current_user.id ) then
      respond_to do |format|
        @tia_item.transaction do
          tia_original = @tia_item.dup
          @tia_item.assign_attributes( tia_item_params ) unless tia_item_params.empty?
          if @tia_item.valid? then
            tia_update = TiaUpdate.new
            tia_update.copy_changes( tia_original, @tia_item )
            if tia_update.valid? then
              tia_update.save!
              @tia_item.save!
              format.html { redirect_to my_tia_item_path( @tia_item ), notice: t( 'our_tia_items.msg.edit_ok' )}
           elsif tia_update.fields_updated == 0 then
              format.html { redirect_to my_tia_item_path( @tia_item ), notice: t( 'our_tia_items.msg.no_change' )}
           else
              @tia_item.errors.add( :base, 'Internal Error: TiaUpdate record failed validation' )
              format.html{ render :edit }
            end
          else
            format.html { render :edit }
          end
        end
      end
    else
      render_no_permission
    end
  end

  # the following actions are not permitted here

  def destroy
    render_no_permission
  end

  def new
    render_no_permission
  end

  def create
    render_no_permission
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    # set the @tia_list (non-existing will cause exception/404 error) and check
    # if current user has permission to access this list and its items

    def set_tia_item
      @tia_item = TiaItem.find( params[ :id ])
      @tia_list = @tia_item.tia_list
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def tia_item_params
      params.require( :tia_item ).permit( :comment )
    end

end