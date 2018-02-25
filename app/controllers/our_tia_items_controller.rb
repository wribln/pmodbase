# TIA items for given TIA list

class OurTiaItemsController < ApplicationController
  include ControllerMethods

  initialize_feature FEATURE_ID_OUR_TIA_ITEMS, FEATURE_ACCESS_USER + FEATURE_ACCESS_NBP, FEATURE_CONTROL_CUG

  before_action :set_tia_list, only: [ :index, :create, :new ]
  before_action :set_tia_item, only: [ :show, :info, :edit, :update, :destroy ]
  before_action :set_member_list, only: [ :index, :new, :edit ]
  before_action :set_breadcrumb

  # GET /tia_items

  def index
    set_breadcrumb_path( my_tia_list_our_tia_items_path( params[ :my_tia_list_id ]))
    @filter_fields = filter_params
    respond_to do |format|
      format.html do
        @tia_items = @tia_list.tia_items.active.filter( filter_params ).paginate( page: params[ :page ], per_page: 5 )
        @tia_stats = nil
      end
      format.doc do
        @tia_items = @tia_list.tia_items.active.filter( filter_params )
        @tia_stats = @tia_list.tia_items.active.filter( filter_params ).group( :status ).count
        set_header( :doc, 'tia-items.doc' )
        render layout: 'plain_docs'
      end
    end
  end

  # GET /tia_items/1

  def show
    set_breadcrumb_path( my_tia_list_our_tia_items_path( @tia_item.tia_list ))
  end

  # get /tia_items/1/indo

  def info
    set_breadcrumb_path( my_tia_list_our_tia_items_path( @tia_item.tia_list ))
    set_final_breadcrumb( :history )
  end

  # GET /tia_items/new

  def new
    set_breadcrumb_path( my_tia_list_our_tia_items_path( params[ :my_tia_list_id ]))
    @tia_item = @tia_list.tia_items.new
    @tia_item.seqno = nil
  end

  # GET /tia_items/1/edit

  def edit
    set_breadcrumb_path( my_tia_list_our_tia_items_path( @tia_item.tia_list ))
  end

  # POST /tia_items

  def create
    @tia_item = @tia_list.tia_items.new( tia_item_params )
    respond_to do |format|
      @tia_item.transaction do
        @tia_item.seqno = @tia_list.next_seqno_for_item
        if @tia_item.save
          format.html { redirect_to our_tia_item_path( @tia_item ), notice: t( 'tia_items.msg.new_ok' )}
        else
          set_member_list
          format.html { render :new }
        end
      end
    end
  end

  # NOTE: this piece of code must be (almost) identical to the corresponding one in
  # MyTiaItemsController: If you change something here, make sure you do it there.

  def update
    respond_to do |format|
      @tia_item.transaction do
        tia_original = @tia_item.dup
        @tia_item.assign_attributes( tia_item_params ) unless tia_item_params.empty?
        if @tia_item.valid? then
          tia_item_delta = TiaItemDelta.new
          tia_item_delta.collect_delta_information( tia_original, @tia_item )
          if tia_item_delta.valid? then
            tia_item_delta.save!
            @tia_item.save!
            format.html { redirect_to our_tia_item_path( @tia_item ), notice: t( 'tia_items.msg.edit_ok'   )}
          elsif tia_item_delta.delta_count == 0 then
            format.html { redirect_to our_tia_item_path( @tia_item ), notice: t( 'tia_items.msg.no_change' )}
          else
            @tia_item.errors.add( :base, 'Internal Error: TiaItemDelta record failed validation' )
            set_member_list
            format.html{ render :edit }
          end
        else
          set_member_list
          format.html { render :edit }
        end
      end
    end
  end

  # DELETE /tia_items/1
 
  def destroy
    @tia_item.destroy
    respond_to do |format|
      format.html { redirect_to my_tia_list_our_tia_items_url( @tia_list ), notice: t( 'tia_items.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    # set the @tia_list (non-existing will cause exception/404 error) and check
    # if current user has permission to access this list and its items

    def set_tia_list
      @tia_list = TiaList.find( params[ :my_tia_list_id ])
      # permit access if current user is either owner or deputy of this list
      render_no_permission unless @tia_list.user_is_owner_or_deputy?( current_user.id )
    end

    def set_tia_item
      @tia_item = TiaItem.find( params[ :id ])
      @tia_list = @tia_item.tia_list
      render_no_permission unless @tia_list.user_is_owner_or_deputy?( current_user.id )
    end

    def set_member_list
      @member_list = Account.find( @tia_list.accounts_for_select ).collect { |a| [ a.person.user_name, a.id ]}
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def tia_item_params
      params.require( :tia_item ).permit( :account_id, :description, :comment, :prio, :status, :due_date, :res_date, :archived )
    end

    def filter_params
      params.slice( :ff_seqno, :ff_desc, :ff_prio, :ff_owner, :ff_status, :ff_due ).clean_up
    end      

    def set_breadcrumb
      parent_breadcrumb( :my_tia_lists, my_tia_lists_path )
    end

end
