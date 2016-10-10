require './lib/assets/work_flow_helper_dyn.rb'
class IsrInterfacesController < ApplicationController

  initialize_feature FEATURE_ID_ISR_INTERFACES, FEATURE_ACCESS_INDEX, FEATURE_CONTROL_GRPWF, 1

  before_action :set_general_workflow
  before_action :set_isr_interface, only: [ :show, :edit, :update, :destroy ]
  before_action :set_all_groups, only: [ :new, :edit ]

  # GET /isr

  def index
    @filter_fields = filter_params
    @filter_states = @workflow.all_states_for_select
    @filter_groups = permitted_groups( :to_index )
    @isr_interfaces = IsrInterface.filter( @filter_fields ).all_permitted( current_user ).paginate( page: params[ :page ])
  end

  # GET /isr/1

  def show
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
    else
      init_current_workflow( 0 )
   end

  end

  # GET /isr/1/edit

  def edit
  end

  # POST /isr

  def create
    @isr_interface = IsrInterface.new( isr_interface_params )
    respond_to do |format|
      if @isr_interface.save
        format.html { redirect_to @isr_interface, notice: I18n.t( 'isr_interfaces.msg.create_ok' )}
      else
        set_isr_groups
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /isr/1

  def update
    respond_to do |format|
      if @isr_interface.update(isr_interface_params)
        format.html { redirect_to @isr_interface, notice: I18n.t( 'isr_interfaces.msg.update_ok' )}
      else
        set_isr_groups
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
      init_current_workflow( 0, nil, @isr_interface.current_status, @isr_interface.current_task )
      @workflow.validate_instance if $DEBUG
    end

    def filter_params
      params.slice( :ff_id, :ff_grp, :ff_txt, :ff_lvl, :ff_sts, :ff_wfs  ).clean_up
    end

    def set_all_groups
      @isr_groups = Group.all.collect{ |g| [ g.code_and_label, g.id ]}
    end

    def permitted_groups( action )
      pg = current_user.permitted_groups( feature_identifier, action )
      Group.permitted_groups( pg ).all.collect{ |g| [ g.code, g.id ]}
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def isr_interface_params
      params.require( :isr_interface ).permit(
        :if_code, :if_level, :l_group_id, :p_group_id, :title, :desc, 
        :current_status, :current_task, :cfr_record_id, :safety_related )
    end

    # setup workflow - call once to initialize object

    def set_general_workflow
      @workflow = WorkFlowHelperDyn.new([
        [ # single workflow only
          [[ 0, 1 ]],
          [[ 1, 2 ],[ 8, 7 ]],
          [[ 2, 3 ],[ 3, 2 ],[ 6, 5 ]],
          [[ 4, 2 ],[ 5, 4 ]],
          [[ 7, 6 ]],
          [[ 9, 7 ]],
          [],
          [[ -1, 7 ]]
        ],
        ],
        controller_name )
    end

    def init_current_workflow( index, group_id = nil, status = 0, task = 0 )
      raise ArgumentError.new( 'init_current_workflow must not be called twice' ) \
        unless @workflow.wf_current_index.nil? 
      @workflow.initialize_current( index, status, task, 
        current_user.permission_to_access( self.feature_identifier, map_action_to_permission, group_id ))
    end

end
