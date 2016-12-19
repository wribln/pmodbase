# This is the general controller for the Interface Status Register.
#
# The following actions are provided
#
# GET /isr              index       Show all IFs + related IAs              all
#
# GET /isr/info         show_info   Display workflow information            all
# GET /isr/stats        show_stats  Display statistics                      all
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
# GET /isr/1/new        new_ia      Create new IA for IF 1, start WF 0      IFM
# GET /isr/1/copy       new_ia_copy Copy this IA, start WF 0 (like new_ia)  IFM
# GET /isr/1/rev        new_ia_rev  Create revision for IA 1, start WF 1    IFM
# GET /isr/1/fin        new_ia_fin  Create termination for IA 1, start WF 2 IFM
# POST /isr/ia          create_ia
#
# GET /isr/1/edit       edit        Edit IF 1                               IFM
# GET /isr/ia/1/edit    edit_ia     Edit IA 1 using WF                      IFL/IFP
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
#            or 'terminated' (previous IA 'superseeded').

require 'isr_work_flow.rb'
class IsrInterfacesController < ApplicationController
  include IsrWorkFlow

  initialize_feature FEATURE_ID_ISR_INTERFACES, FEATURE_ACCESS_VIEW, FEATURE_CONTROL_WF, 3

  before_action :set_workflow
  before_action :load_data_from_if, only: [ :show,    :show_all,                  :edit,    :update,    :destroy    ]
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
  end

  def show_ia
    set_final_breadcrumb( :show )
  end

  def show_ia_all
    set_final_breadcrumb( :all )
  end

  def show_ia_icf
    @res_steps_items = @isr_agreement.res_steps.tia_items.active unless @isr_agreement.res_steps.nil?
    @val_steps_items = @isr_agreement.val_steps.tia_items.active unless @isr_agreement.val_steps.nil?
    render layout: 'plain_print'
  end

  # create new IF

  def new
    @isr_interface = IsrInterface.new
    set_selections( :to_create )
  end

  # create new IA based on this IF

  def new_ia
    set_final_breadcrumb( :new )
    @isr_interface = IsrInterface.find( params[ :id ])
    @isr_agreement = @isr_interface.isr_agreements.build
    @isr_agreement.prepare_revision( 0 )
    initialize_current_workflow
    set_selections( :to_create )
  end

  # create new IA based on this IA

  def new_ia_copy
    prepare_new_ia( 0 )
  end

  def new_ia_rev
    prepare_new_ia( 1, @isr_agreement.id )
  end

  def new_ia_fin
    prepare_new_ia( 2, @isr_agreement.id )
  end

  def prepare_new_ia( ia_type, based_on_id = nil )
    set_final_breadcrumb( :new )
    @isr_agreement = @isr_agreement.dup
    @isr_agreement.based_on_id = based_on_id
    @isr_agreement.prepare_revision( ia_type )
    @workflow.initialize_current( ia_type, 0, 0 )
    set_selections( :to_create )
    render :new_ia
  end    
  private :prepare_new_ia    

  # GET /isr/1/edit

  def edit
    set_selections( :to_update )
  end

  def edit_ia
    if @workflow.permitted_params.empty? and not @workflow.status_change_possible? then
      redirect_to @isr_agreement, notice: I18n.t( 'isr_interfaces.msg.no_edit_now' )
    else
      set_final_breadcrumb( :edit )
      set_selections( :to_update )
    end
  end

  # POST /isr

  def create
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
    set_final_breadcrumb( :create )
    @isr_interface = IsrInterface.find( params[ :id ])
    @isr_interface.assign_attributes( isr_interface_params )
    ia_type = params.fetch( :isr_agreement ).fetch( :ia_type ).to_i
    @workflow.initialize_current( ia_type, 0, 0 )
    @isr_agreement = @isr_interface.isr_agreements.build( isr_agreement_params )
    @isr_agreement.prepare_revision( ia_type )
    @isr_agreement.set_next_ia_no
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
    #if @workflow.permitted_params.empty? and not @workflow.status_change_possible? then
    #  redirect_to @isr_interface, notice: I18n.t( 'isr_interfaces.msg.no_edit_now' )
    #else
      respond_to do |format|
        if @isr_interface.update( isr_interface_params )
          format.html { redirect_to isr_interface_details_path( @isr_interface ), notice: I18n.t( 'isr_interfaces.msg.update_ok' )}
        else
          set_selections( :to_update )
          format.html { render :edit }
        end
      end
    #end
  end

  def update_ia
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
      respond_to do |format|
        @isr_agreement.assign_attributes( isr_agreement_params )
        @isr_interface.assign_attributes( isr_interface_params )
        update_status_and_task( nst )
        if @isr_interface.valid? && @isr_agreement.valid?
          IsrAgreement.transaction do
            @isr_agreement.save!
            @isr_interface.save!
          end
          format.html { redirect_to redirect_path, notice: I18n.t( 'isr_interfaces.msg.update_ia_ok' )}
        else
          set_final_breadcrumb( :edit )        
          set_selections( :to_update )
          @workflow.initialize_current( 0 )
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
      case @workflow.wf_updated_status
        when 3
          @isr_agreement.l_signature = current_user.account_info
          @isr_agreement.l_sign_time = DateTime.now
          @isr_interface.if_status = 2 if @isr_interface.if_status < 2
        #  @isr_agreement.freeze_cfr_record
        when 4
        #  @isr_agreement.unfreeze_cfr_record
          @isr_agreement.l_sign_time = nil
          @isr_agreement.l_signature = nil
        when 5
          @isr_agreement.p_signature = current_user.account_info
          @isr_agreement.p_sign_time = DateTime.now
        when 8
          @isr_agreement.ia_status = 1 # agreed
        when 9
          @isr_agreement.ia_status = 7 # withdrawn
      end
      @isr_agreement.errors.empty? && @isr_interface.errors.empty?
    end

end
