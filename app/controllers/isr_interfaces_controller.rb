# This is the general controller for the Interface Status Register.
#
# The following actions are provided
#
# GET /isr              index       Show all IFs + related IAs              all
#
# GET /isr/info         show_info   Display workflow information            all
#
# GET /isr/1            show        Show IF 1 + related IAs / short         all
# GET /isr/1/all        show_all    Show IF 1 / detailed                    all
#
# GET /isr/ia/1         show_ia     Show IA 1 + related IF / short          all
# GET /isr/ia/1/all     show_ia_all Show IA 1 + related IF / detailed       all
# GET /isr/ia/1/icf     show_ia_icf Show IA 1 + related IF / print (ICF)    all
#
# GET /isr/new          new         Create new IF                           IFM
# POST /isr             create      
#
# This is slightly tricky as the :id is used for both IF and IA, depending
# on the second routing parameter :wt (workflow type)
#
# GET /isr/1/new        new_ia      Create new IA for IF 1, start WF 0      IFM
# GET /isr/1/new?wt=0               Create new IA as copy of IA 1 with WF 0
# GET /isr/1/new?wt=1               Revise IA
# GET /isr/1/new?wt=2               Terminate IA
# GET /isr/1/new?wt=3               Change IA status to resolved
# GET /isr/1/new?wt=4               Change IA status to closed
# GET /isr/1/new?wt=5               Create new IA for IF of IA 1 with WF 0 
# POST /isr/ia          create_ia
#
# GET /isr/1/edit       edit        Edit IF 1                               IFM
# GET /isr/ia/1/edit    edit_ia     Edit IA 1 using WF                      IFL/IFP
# GET /isr/1/wdr        edit_wdr    Withdraw IF 1 and associated, open IAs  IFM
#
# PATCH/PUT /isr/1      update      Update IF 1                             IFM
# PATCH/PUT /isr/ia/1   update_ia   Update IA 1                             IFL/IFP
# 
# DELETE /isr/1         destroy     Remove IF 1                             IFM
# DELETE /isr/ia/1      destroy_ia  Remove IA 1                             IFM
#
#
# There are 2 workflows for IAs
#
# 1. create
# 2. revise, i.e. any change after initial agreement, including termination;
#            implemented as new revision where result could be 'agreed'
#            or 'terminated' (previous IA 'superseded').

require 'isr_work_flow.rb'
class IsrInterfacesController < ApplicationController
  include IsrWorkFlow

  initialize_feature FEATURE_ID_ISR_INTERFACES, FEATURE_ACCESS_VIEW, FEATURE_CONTROL_WF, 5

  before_action :set_workflow
  before_action :load_data_from_if, only: [ :show, :show_all, :edit, :edit_wdr, :update, :destroy ]
  before_action :load_data_from_ia, only: [ :show_ia, :show_ia_all, :show_ia_icf, :edit_ia, :update_ia, :destroy_ia, 
                                            :new_ia_rev, :new_ia_fin, :new_ia_copy ]
  
  def index
    @filter_fields = filter_params
    @filter_states = @workflow.all_states_for_select
    @filter_groups = Group.active_only.participants_only.collect{ |g| [ g.code, g.id ]}
    @isr_interfaces = IsrInterface.includes( :active_agreements ).filter( @filter_fields ).all.paginate( page: params[ :page ])
  end

  def info_workflow
  end

  def show
  end

  def show_all
    set_final_breadcrumb( :show )
  end

  def show_ia
    set_final_breadcrumb( :show )
  end

  def show_ia_all
    set_final_breadcrumb( :show )
  end

  def show_ia_icf
    @res_steps_items = @isr_agreement.res_steps.tia_items.active unless @isr_agreement.res_steps.nil?
    @val_steps_items = @isr_agreement.val_steps.tia_items.active unless @isr_agreement.val_steps.nil?
    render layout: 'plain_print'
  end

  # create new IF

  def new
    unless user_has_ifm_access?( :to_create )
      render_no_permission
      return
    end
    @isr_interface = IsrInterface.new
    set_selections( :to_create )
  end

  # create new IA via IF

  def new_ia
    set_final_breadcrumb( :new )
    unless user_has_ifm_access?( :to_create )
      render_no_permission
      return
    end
    case wt = params.fetch( :wt, -1 ).to_i
    when -1
      @isr_interface = IsrInterface.find( params[ :id ])
      @isr_agreement = @isr_interface.isr_agreements.build
      @isr_agreement.l_group_id = @isr_interface.l_group_id
      @isr_agreement.p_group_id = @isr_interface.p_group_id
      @isr_agreement.prepare_revision( 0 )
    when 0..4
      prev_ia = @isr_agreement = IsrAgreement.find( params[ :id ])
      @isr_interface = @isr_agreement.isr_interface
      @isr_agreement = @isr_agreement.dup
      @isr_agreement.prepare_revision( wt, prev_ia )
    when 5
      @isr_agreement = IsrAgreement.find( params[ :id ])
      @isr_interface = @isr_agreement.isr_interface
      @isr_agreement = @isr_interface.isr_agreements.build
      @isr_agreement.l_group_id = @isr_interface.l_group_id
      @isr_agreement.p_group_id = @isr_interface.p_group_id
      @isr_agreement.prepare_revision( 0 )
    else
      raise ArgumentError.new( "bad parameter value wt: #{ wt }." )
    end 
    unless ia_status_ok?
      render_bad_logic I18n.t( 'isr_interfaces.msg.bad_ia_status' )
      return
    end
    initialize_current_workflow
    set_selections( :to_create )
  end

  # create new IA based on this IA

  def new_wf
    unless user_has_ifm_access?( :to_create )
      render_no_permission
      return
    end
    set_final_breadcrumb( :new )
    @isr_agreement = IsrAgreement.find( params[ :id ])
    @isr_interface = @isr_agreement.isr_interface
  end

  # edit IF attributes

  def edit
    unless user_has_ifm_access?( :to_update )
      render_no_permission
      return
    end
    unless if_status_ok?
      render_bad_logic t( 'isr_interfaces.msg.bad_if_status' )
      return
    end
    set_selections( :to_update )
  end

  # edit IF and IA attributes

  def edit_ia
    unless user_has_access?
      render_no_permission
      return
    end
    set_final_breadcrumb( :edit )
    if @workflow.permitted_params.empty? and not @workflow.status_change_possible? then
      redirect_to @isr_agreement, notice: I18n.t( 'isr_interfaces.msg.no_edit_now' )
    else
      set_selections( :to_update )
    end
  end

  # withdraw IF and associated IAs - same as edit here

  def edit_wdr
    edit
  end

  # POST /isr

  def create
    unless user_has_ifm_access?( :to_update )
      render_no_permission
      return
    end
    @isr_interface = IsrInterface.new( isr_interface_params )
    respond_to do |format|
      if @isr_interface.save
        format.html { redirect_to isr_interface_details_path( @isr_interface ), notice: I18n.t( 'isr_interfaces.msg.create_ok' )}
      else
        set_selections( :to_create )
        format.html { render :new }
      end
    end
  end

  def create_ia
    unless user_has_ifm_access?( :to_create )
      render_no_permission
      return
    end
    set_final_breadcrumb( :create )
    @isr_interface = IsrInterface.find( params[ :id ])
    @isr_interface.assign_attributes( isr_interface_params )
    ia_type = params.fetch( :isr_agreement ).fetch( :ia_type ).to_i
    @workflow.initialize_current( ia_type, 0, 0 )
    @isr_agreement = @isr_interface.isr_agreements.build( isr_agreement_params )
    @isr_agreement.prepare_revision( ia_type, @isr_agreement.based_on )
    unless ia_status_ok?
      render_bad_logic t( 'isr_interfaces.msg.bad_ia_status' )
      return
    end
    update_status_and_task
    respond_to do |format|
      if @isr_agreement.valid? && @isr_interface.valid?
        IsrAgreement.transaction do
          @isr_agreement.save!
          @isr_interface.save!
        end
        format.html { redirect_to isr_agreement_details_path( @isr_agreement ), notice: I18n.t( 'isr_interfaces.msg.create_ia_ok' )}
      else
        set_selections( :to_create )
        format.html { render :new_ia }
      end
    end
  end

  # PATCH/PUT /isr/1

  def update
    unless user_has_ifm_access?( :to_update )
      render_no_permission
      return
    end
    unless if_status_ok?
      render_bad_logic t( 'isr_interfaces.msg.bad_if_status' )
      return
    end
    respond_to do |format|
      @isr_interface.assign_attributes( isr_interface_params )
      if params[ :commit ] == I18n.t( 'button_label.wdr' )
        @isr_interface.withdraw
        r_url = isr_interface_path( @isr_interface )
        r_msg = t( 'isr_interfaces.msg.wdr_ok' )
        r_lnk = :edit_wdr
      else
        r_url = isr_interface_details_path( @isr_interface )
        r_msg = t( 'isr_interfaces.msg.update_ok' )
        r_lnk = :edit
      end
      if @isr_interface.save
        format.html { redirect_to r_url, notice: r_msg }
      else
        set_selections( :to_update )
        format.html { render r_lnk }
      end
    end
  end

  def update_ia
    unless user_has_access?
      render_no_permission
      return
    end
    if @workflow.permitted_params.empty? and not @workflow.status_change_possible? then
      redirect_to @isr_interface, notice: I18n.t( 'isr_interfaces.msg.no_edit_now' )
    else
      # for view with confirm / reject buttons, determine next_status_task
      # redirect to short view rather than detail view, too.
      redirect_path = isr_agreement_details_path( @isr_agreement )
      nst = params.fetch( :next_status_task, -1 ).to_i
      if nst < 0 then # next_status_task missing / assume confirm or reject
        redirect_path = isr_agreement_path( @isr_agreement )
        if params[ :commit ] == I18n.t( 'isr_interfaces.edit.confirm' )
          nst = 1
        elsif params[ :commit ] == I18n.t( 'isr_interfaces.edit.reject' )
          nst = 2
        else
          nst = 0 # no change
        end
      end
      @isr_agreement.assign_attributes( isr_agreement_params )
      @isr_interface.assign_attributes( isr_interface_params )
      update_status_and_task( nst ) # also performs validations!
      respond_to do |format|
        if @isr_interface.errors.empty? && @isr_agreement.errors.empty?
          IsrAgreement.transaction do
            @isr_agreement.save!
            @isr_interface.save!
          end
          format.html { redirect_to redirect_path, notice: I18n.t( 'isr_interfaces.msg.update_ia_ok' )}
        else
          set_final_breadcrumb( :edit )        
          set_selections( :to_update )
          initialize_current_workflow
          format.html { render :edit_ia }
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

  # DELETE /isr/ia/1

  def destroy_ia
    @isr_agreement.destroy
    respond_to do |format|
      format.html { redirect_to isr_interfaces_url, notice: I18n.t( 'isr_interfaces.msg.delete_ia_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def load_data_from_if
      @isr_interface = IsrInterface.find( params[ :id ])
      @isr_agreements = @isr_interface.active_agreements
    end

    def load_data_from_ia
      @isr_agreement = IsrAgreement.find( params[ :id ])
      @isr_interface = @isr_agreement.isr_interface
      initialize_current_workflow
    end

    def initialize_current_workflow
      @workflow.initialize_current( @isr_agreement.ia_type, @isr_agreement.current_status, @isr_agreement.current_task )
    end      

    def filter_params
      params.slice( :ff_id, :ff_grp, :ff_txt, :ff_lvl, :ff_sts, :ff_ats, :ff_wfs  ).clean_up
    end

    def set_selections( action )
      @isr_p_groups = Group.active_only.participants_only.collect{ |g| [ g.code_and_label, g.id ]}
      pg = current_user.permitted_groups( feature_identifier, action )
      @isr_l_groups = Group.permitted_groups( pg ).active_only.participants_only.collect{ |g| [ g.code_and_label, g.id ]}
      @isr_sel_states = [[ 0, 1, 3 ],[ 0, 1, 3 ]][ @isr_interface.if_status ]
      @isr_sel_states.map!{ |l| [ IsrInterface::ISR_IF_STATUS_LABELS[ l ], l ]} unless @isr_sel_states.nil?
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def isr_interface_params
      valid_params = [ :note ] # always possible
      valid_params.push( :desc, :cfr_record_id, 
        :l_group_id, :p_group_id, :title, :desc, 
        :safety_related, :if_status, :if_level ) unless @isr_interface.frozen?
      params.require( :isr_interface ).permit( valid_params )
    end

    def isr_agreement_params
      @workflow.permitted_params.empty? ? {} : params.require( :isr_agreement ).permit( @workflow.permitted_params )
    end

    # determine if status allows requested action:
    # IF must not be closed, i.e. withdrawn, or not applicable
    # IA must be agreed
    #    let test pass if isa is not given (although required):
    #    validation should take care of this issue.

    def if_status_ok?
      ![ 3, 4 ].include?( @isr_interface.if_status )
    end

    def ia_status_ok?
      return false unless if_status_ok?
      isa = @isr_agreement.based_on
      return true if isa.nil?
      case @isr_agreement.ia_type
      when 1, 2, 3, 4 # revision, termination, resolve, close - only on agreed IAs
        [ 1 ].include? isa.ia_status
      else
        true
      end
    end

    # helper method which determines whether to show only confirm and reject buttons

    def confirm_or_reject?
      case @isr_agreement.ia_type
      when 0, 1
        @isr_agreement.current_task == 3
      when 2, 3, 4
        [ 2, 3 ].include? @isr_agreement.current_task
      else
        false
      end
    end
    helper_method :confirm_or_reject?

    # this method determines the next status and task for agreements

    def update_status_and_task( i = 1 )
      @workflow.update_status_task( i )
      if ready_for_next_status_task? then
        @isr_agreement.current_task = @workflow.wf_updated_task
        @isr_agreement.current_status = @workflow.wf_updated_status
      end
    end

    def ready_for_next_status_task?
      return false unless @isr_agreement.valid? && @isr_interface.valid?
      # need l_owner or l_deputy to prepare agreement or confirm status change
      if @workflow.wf_updated_task == 2 && 
         @isr_agreement.l_owner_id.nil? &&
         @isr_agreement.l_deputy_id.nil? then
        @isr_agreement.errors.add( :l_owner_id, t( 'isr_interfaces.msg.req_next_step' ))
      end
      case @isr_agreement.ia_type
      when 0, 1 # new and revision
        case @workflow.wf_updated_status
        when 0 # new, revised agreement
          if action_name == 'create_ia' && !@isr_agreement.based_on.nil? # implies ia_type == 1
            @isr_agreement.based_on.ia_status = 4 # in revision
          end
        when 3 # agreement, revision to be released
          # need p_owner or p_deputy to confirm agreement
          @isr_agreement.errors.add( :p_owner_id, t( 'isr_interfaces.msg.req_next_step' )) \
            if @isr_agreement.p_owner_id.nil? && @isr_agreement.p_deputy_id.nil?
          # definition must not be empty
          @isr_agreement.errors.add( :def_text, t( 'isr_interfaces.msg.req_next_step' )) \
            if @isr_agreement.def_text.blank?
          if @isr_agreement.errors.empty?
            @isr_agreement.l_signature = current_user.account_info
            @isr_agreement.l_sign_time = DateTime.now
            @isr_interface.if_status = 2 if @isr_interface.if_status < 2
          end
        when 5 # revision confirmed
          @isr_agreement.p_signature = current_user.account_info
          @isr_agreement.p_sign_time = DateTime.now
        when 6 # revision rejected
          @isr_agreement.l_sign_time = nil
          @isr_agreement.l_signature = nil
        when 8 # agreed
          @isr_agreement.ia_status = 1 # agreed
          @isr_agreement.based_on.ia_status = 6 unless @isr_agreement.based_on.nil? # implies ia_type == 1
        when 9 # withdrawn / cancelled
          if @isr_agreement.ia_type == 0
            @isr_agreement.ia_status = 10
          else
            @isr_agreement.ia_status = 8 
            @isr_agreement.based_on.ia_status = 1 unless @isr_agreement.based_on.nil? # implies ia_type == 1
          end
        end
      when 2, 3, 4
        case @workflow.wf_updated_status
        when 0
          if action_name == 'create_ia' && !@isr_agreement.based_on_id.nil?
            @isr_agreement.based_on.ia_status = 5 # in status change
          end
        when 1
          # need p_owner or p_deputy to confirm agreement
          @isr_agreement.errors.add( :p_owner_id, t( 'isr_interfaces.msg.req_next_step' )) \
            if @isr_agreement.p_owner_id.nil? && @isr_agreement.p_deputy_id.nil?
          # definition must not be empty
          @isr_agreement.errors.add( :def_text, t( 'isr_interfaces.msg.req_next_step' )) \
            if @isr_agreement.def_text.blank?
        when 2 # status change confirmed by IFL
          @isr_agreement.l_signature = current_user.account_info
          @isr_agreement.l_sign_time = DateTime.now
        when 3 # status change confirmed by IFP
          @isr_agreement.p_signature = current_user.account_info
          @isr_agreement.p_sign_time = DateTime.now
        when 4 # status change completed
          @isr_agreement.based_on.ia_status = 6 # superseded
          if @isr_agreement.ia_type == 2
            @isr_agreement.terminate_ia
          elsif @isr_agreement.ia_type == 3
            @isr_agreement.resolve_ia
          elsif @isr_agreement.ia_type == 4
            @isr_agreement.close_ia
          end
        when 6 # status change rejected by IFP
          @isr_agreement.l_sign_time = nil
          @isr_agreement.l_signature = nil
        end
     end
      @isr_agreement.errors.empty? && @isr_interface.errors.empty?
    end

    # determine if current user has permission for given action
    # IFM needs permission level 2, IFL/IFP need 1

    def user_has_ifm_access?( action )
      a = current_user.permission_to_access( FEATURE_ID_ISR_INTERFACES, action )
      a ? a > 1 : false
    end

    def user_has_ifl_access?
      current_user.id == @isr_agreement.l_owner_id || current_user.id == @isr_agreement.l_deputy_id 
    end

    def user_has_ifp_access?
      current_user.id == @isr_agreement.p_owner_id || current_user.id == @isr_agreement.p_deputy_id 
    end      

    # The following method heavily depends on the fact that all workflows
    # use the same task number for IFM-/IFL-/IFP-specific tasks !!!

    def user_has_access?
      case @isr_agreement.current_task
      when 0
        user_has_ifm_access?( :to_create )
      when 1, 4, 5 # create, archive, modify
        user_has_ifm_access?( :to_update )
      when 2
        user_has_ifl_access?
      when 3
        user_has_ifp_access?
      else
        false
      end
    end
end
