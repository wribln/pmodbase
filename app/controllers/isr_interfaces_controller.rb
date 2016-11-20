require './lib/assets/work_flow_helper.rb'
class IsrInterfacesController < ApplicationController

  initialize_feature FEATURE_ID_ISR_INTERFACES, FEATURE_ACCESS_VIEW, FEATURE_CONTROL_GRPWF, 1

  before_action :set_general_workflow
  before_action :set_isr_interface, only: [ :show, :show_icf, :edit, :update, :destroy ]
  
  # GET /isr

  def index
    @filter_fields = filter_params
    @filter_states = @workflow.all_states_for_select
    @filter_groups = all_groups
    @isr_interfaces = IsrInterface.filter( @filter_fields ).all.paginate( page: params[ :page ])
  end

  # GET /isr/1

  def show
  end

  # GET /isr/1/icf

  def show_icf
    render :icf, layout: 'plain_print'
  end

  # GET /isr/info

  def info_workflow
  end

  # GET /isr

  def new
    @isr_interface = IsrInterface.new
    @allowed_workflows = current_user.permitted_workflows( feature_identifier )
    if @allowed_workflows.blank?
      redirect_to @isr_interface, notice: t( 'isr_interfaces.msg.you_no_new')
    end
    @workflow.initialize_current( 0, 0, 1 )
    set_selections( :to_create )
  end

  # GET /isr/1/edit

  def edit
    if @workflow.permitted_params.empty? and not @workflow.status_change_possible? then
      redirect_to @isr_interface, notice: t( 'isr_interfaces.msg.no_edit_now' )
    elsif !current_user.permission_for_task_for_group?( feature_identifier, 0, @isr_interface.current_task, @isr_interface.l_group_id, :to_update )
      redirect_to @isr_interface, notice: t( 'isr_interfaces.msg.you_no_edit' )
    end
    set_selections( :to_update )
  end

  # POST /isr

  def create
    @workflow.initialize_current( 0 )
    @isr_interface = IsrInterface.new( isr_interface_params )
    unless current_user.permission_for_task_for_group?( feature_identifier, 0, 0, @isr_interface.l_group_id, :to_create )
      redirect_to @isr_interface, notice: t( 'isr_interfaces.msg.you_no_new' )
    else # permission granted to create workflow
      update_status_and_task
      respond_to do |format|
        if @isr_interface.save
          format.html { redirect_to @isr_interface, notice: I18n.t( 'isr_interfaces.msg.create_ok' )}
        else
          set_selections( :to_create )
          format.html { render :new }
        end
      end
    end
  end

  # PATCH/PUT /isr/1

  def update
    # check permissions - again, to be on the safe side
    if @workflow.permitted_params.empty? and not @workflow.status_change_possible? then
      redirect_to @isr_interface, notice: I18n.t( 'isr_interfaces.msg.no_edit_now' )
    elsif !current_user.permission_for_task_for_group?( feature_identifier, 0, @isr_interface.current_task, @isr_interface.l_group_id, :to_update )
      redirect_to @isr_interface, notice: I18n.t( 'isr_interfaces.msg.you_no_edit' )
    else
      # get ready to update record
      nst = params.fetch( :next_status_task, -1 ).to_i
      if nst < 0 then # next_status_task missing
        if params[ :commit ] == I18n.t( 'isr_interfaces.edit.confirm' )
          nst = 1
        elsif params[ :commit ] == I18n.t( 'isr_interfaces.edit.reject' )
          nst = 2
        else
          nst = 0 # no change
        end
      end
      update_status_and_task( nst )
      respond_to do |format|
        if @isr_interface.update( isr_interface_params )
          format.html { redirect_to @isr_interface, notice: I18n.t( 'isr_interfaces.msg.update_ok' )}
        else
          set_selections( :to_update ) if @workflow.param_permitted?( :p_group_id ) || @workflow.param_permitted?( :l_group_id )
          format.html { render :edit }
        end
      end
    end
  end

  # DELETE /isr/1

  def destroy
    @isr_interface.destroy
    respond_to do |format|
      format.html { redirect_to isr_interfaces_url, notice: I18n.t( 'isr_interfaces.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_isr_interface
      @isr_interface = IsrInterface.find( params[ :id ])
      @workflow.initialize_current( 0, @isr_interface.current_status, @isr_interface.current_task )
      @workflow.validate_instance if $DEBUG
    end

    def filter_params
      params.slice( :ff_id, :ff_grp, :ff_txt, :ff_lvl, :ff_sts, :ff_wfs  ).clean_up
    end

    def all_groups
      Group.all.collect{ |g| [ g.code_and_label, g.id ]}
    end

    def set_selections( action )
      @isr_p_groups = all_groups
      pg = current_user.permitted_groups( feature_identifier, action )
      @isr_l_groups = Group.permitted_groups( pg ).all.collect{ |g| [ g.code, g.id ]}
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def isr_interface_params
      params.include?( :isr_interface ) ? params.require( :isr_interface ).permit( @workflow.permitted_params ) : {}
    end

    # setup workflow - call once to initialize object

    def set_general_workflow
      @workflow = WorkFlowHelper.new([
        [ # single workflow only
          [[ 0, 1 ]],
          [[ 1, 2 ],[ 10, 8 ]],
          [[ 2, 2 ],[ 3, 3 ],[ 6, 6 ],[ 8, 7 ]],
          [[ 4, 4 ],[ 9, 2 ]], # confirm, reject
          [[ 5, 5 ]],
          [[ -1, 8 ]],
          [[ 7, 2 ]],
          [[ 11, 8 ]],
          [[ -1, 8 ]]
        ],
        ],
        [
          [
            [ :if_level, :l_group_id, :p_group_id, :title, :desc, :cfr_record_id, :safety_related, :cfr_record_id, :next_status_task ],
            [ :if_level, :l_group_id, :p_group_id, :title, :desc, :cfr_record_id, :safety_related, :cfr_record_id, :next_status_task ],
            [ :p_group_id, :desc, :cfr_record_id, :next_status_task ],
            [],
            [ :next_status_task ],
            [],
            [ :if_level, :l_group_id, :p_group_id, :title, :desc, :cfr_record_id, :safety_related, :next_status_task ],
            [ :next_status_task ],
            []
          ]
        ],
        controller_name )
      @workflow.validate_instance # if $DEBUG
    end

    # allow task specific views

    def confirm_or_reject
      @isr_interface.current_task == 3
    end
    helper_method :confirm_or_reject

    # determine next status and task - if possible
    # also set IF status:
    # 0    1          2       3      4        5
    # open,identified,defined,agreed,resolved,closed

    def update_status_and_task( i = 1 )
      @workflow.update_status_task( i )
      if ready_for_next_status_task? then
        @isr_interface.current_task = @workflow.wf_updated_task
        @isr_interface.current_status = @workflow.wf_updated_status
        @isr_interface.if_status = 
        #   0, 1, 2, 3, 4, 5, 6, 7, 8, 9 10 11 12 - new status
          [ 0, 1, 1, 1, 2, 2, 1, 1, 1, 1, 5, 5, 5 ][ @isr_interface.current_status ]
      end
    end

    def ready_for_next_status_task?
      return false unless @isr_interface.valid?
      case @workflow.wf_updated_status
        when 3
          @isr_interface.l_signature = current_user.account_info
          @isr_interface.l_sign_time = DateTime.now
          @isr_interface.freeze_cfr_record
        when 4
          @isr_interface.p_signature = current_user.account_info
          @isr_interface.p_sign_time = DateTime.now
        when 9
          @isr_interface.unfreeze_cfr_record
          @isr_interface.l_sign_time = nil
          @isr_interface.l_signature = nil
      end
      @isr_interface.errors.empty?
    end

end
