require 'isr_work_flow.rb'
class IsrInterfacesController < ApplicationController
  include IsrWorkFlow

  initialize_feature FEATURE_ID_ISR_INTERFACES, FEATURE_ACCESS_VIEW, FEATURE_CONTROL_GRP

  before_action :set_workflow
  before_action :set_isr_interface, only: [ :show, :show_all, :show_icf, :edit, :edit_withdraw, :update, :destroy ]
  
  # GET /isr

  def index
    @filter_fields = filter_params
    @filter_states = @workflow.all_states_for_select( 0 )
    @filter_groups = Group.active_only.participants_only.collect{ |g| [ g.code, g.id ]}
    @isr_interfaces = IsrInterface.includes( :active_agreements ).filter( @filter_fields ).all.paginate( page: params[ :page ])
  end

  # GET /isr/1

  def show
  end

  def show_all
  end

  # GET /isr

  def new
    @isr_interface = IsrInterface.new
    set_selections( :to_create )
  end

  # GET /isr/1/edit

  def edit
    set_selections( :to_update )
  end

  # GET /isr/1/wdr - withdraw IF: only possible if status is defined-frozen

  def edit_withdraw
    if [ 3, 4 ].include? @isr_interface.if_status
      redirect_to isr_interface_details_path( @isr_interface ), notice: I18n.t( 'isr_interfaces.msg.wdr_not_now' )
    else
      @isr_interface.if_status = 4 # new status
      @isr_withdrawing = true
      flash.now[ :notice ] = I18n.t( 'isr_interfaces.msg.withdrawing' ) 
      render :edit
    end
  end

  # POST /isr

  def create
    @isr_interface = IsrInterface.new( isr_interface_params )
    respond_to do |format|
      if @isr_interface.save
        format.html { redirect_to @isr_interface, notice: I18n.t( 'isr_interfaces.msg.create_ok' )}
      else
        set_selections( :to_create )
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /isr/1

  def update
    @isr_interface.withdraw unless params[ :isr_withdrawing ].nil?
    respond_to do |format|
      if @isr_interface.update( isr_interface_params )
        format.html { redirect_to isr_interface_details_path( @isr_interface ), notice: I18n.t( 'isr_interfaces.msg.update_ok' )}
      else
        set_selections( :to_update )
        format.html { render :edit }
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
      @isr_agreements = @isr_interface.active_agreements
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
      if @isr_interface.frozen?
        params.require( :isr_interface ).permit( :note )
      else
        params.require( :isr_interface ).permit( :l_group_id, :p_group_id, :title, :desc, 
          :cfr_record_id, :safety_related, :if_status, :if_level, :note )
      end
    end

end
