# this controller processes only individual SIR Entries:
#
#       sir_item_sir_entries POST   /sii/:sir_item_id/sie          sir_entries#create
#              edit_sir_entry GET    /sie/:id/edit                  sir_entries#edit
#

class SirEntriesController < ApplicationController

  initialize_feature FEATURE_ID_SIR_ITEMS, FEATURE_ACCESS_USER + FEATURE_ACCESS_NBP, FEATURE_CONTROL_CUG
  before_action :set_sir_entry, only: [ :show, :edit, :update, :destroy ]

  # GET /sie/:id
 
  def show
    check_access( :to_read )
    set_breadcrumb
  end

  # GET /sii/:sir_item_id/sie/new

  def new
    @sir_item = SirItem.find( params[ :sir_item_id ])
    set_breadcrumb
    set_group_stack_and_last
    check_access( :to_create )
    @sir_entry = @sir_item.sir_entries.new( params.permit( :sir_item_id, :rec_type ))
    set_sir_groups
  end

  # GET /sii/:id/edit

  def edit
    if @sir_entry.updatable?
      set_group_stack_and_last
      check_access( :to_update )
      set_sir_groups
    else
      redirect_to @sir_entry, notice: I18n.t( 'sir_items.msg.bad_upd_req' )
    end
  end

  # POST /sii/:sir_item_id

  def create
    @sir_item = SirItem.find( params[ :sir_item_id ])
    @sir_entry = @sir_item.sir_entries.new( sir_entry_params )
    check_access( :to_create )
    respond_to do |format|
      if @sir_entry.save
        format.html { redirect_to @sir_entry, notice: I18n.t( 'sir_entries.msg.create_ok' )}
      else
        set_sir_groups
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /sie/1
 
  def update
    check_access( :to_update )
    respond_to do |format|
      if @sir_entry.update( sir_entry_params )
        format.html { redirect_to @sir_entry, notice: I18n.t( 'sir_entries.msg.update_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /sie/1
 
  def destroy
    check_access( :to_delete )
    @sir_item = @sir_entry.sir_item
    respond_to do |format|
      if @sir_entry.destroy
        format.html { redirect_to sir_item_path( @sir_item ), notice: I18n.t( 'sir_entries.msg.delete_ok' )}
      else
        format.html { render :show }
      end
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions

    def set_sir_entry
      @sir_entry = SirEntry.find( params[ :id ])
      @sir_item = @sir_entry.sir_item
    end

    # prepare list of groups to choose from - depends on type of entry and action

    def set_sir_groups
      case action_name
      when 'new'
        case @sir_entry.rec_type
        when 0 # forward
          @sir_entry.group_id = nil
          @sir_groups = Group.all.active_only.collect{ |g| [ g.code_and_label, g.id ] unless @group_stack.include?( g.id )}.compact!
        when 1 # comment - use current group
          @sir_entry.group_id = @group_stack.last
          @sir_groups = nil
        when 2 # response - use group before current group
          if @group_stack.size < 2
            @sir_entry.errors.add( :base, I18n.t( 'sir_entries.msg.bad_request' ))
          else
            @sir_entry.group_id = @group_stack[ -2 ]
          end
          @sir_groups = nil
        end
      when 'edit'
        case @sir_entry.rec_type
        when 0 # forward
          @sir_groups = Group.all.active_only.collect{ |g| [ g.code_and_label, g.id ]}
        when 1 # comment - use current group
          @sir_groups = nil
        when 2 # response - use group before current group
          @sir_groups = nil
        end
      end
    end

    def set_group_stack_and_last
      @group_stack = @sir_item.group_stack
      @last_entry = @sir_item.sir_entries.last
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def sir_entry_params
      params.require( :sir_entry ).permit( 
        :sir_item_id, :rec_type, :group_id, :due_date, :description )
    end

    def set_breadcrumb
      parent_breadcrumb( :sir_logs, sir_logs_path )
      parent_breadcrumb( :sir_items, sir_log_sir_items_path( @sir_item.sir_log ))
      set_breadcrumb_path( sir_item_path( @sir_item ))
    end

    # only owner, deputy and members of this SIR log may access details
    # only members with access to group may view/update item

    def check_access( action )
      render_no_access unless @sir_item.sir_log.permitted_to_access?( current_user.id )
      g = @sir_entry.try( :group_id ) || @last_entry.group_id
      render_no_permission unless current_user.permission_to_access( feature_identifier, action, g )
    end

end
