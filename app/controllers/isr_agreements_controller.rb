require 'isr_work_flow.rb'
class IsrAgreementsController < ApplicationController
  include IsrWorkFlow

  initialize_feature FEATURE_ID_ISR_AGREEMENTS, FEATURE_ACCESS_READ

  before_action :set_workflow
  before_action :set_isr_agreement, only: [ :show, :show_all, :show_icf, :new_revise, :edit, :update, :destroy ]

  # GET /isa

  def index
    @filter_fields = filter_params
    @filter_states = @workflow.all_states_for_select( 0 )
    @filter_groups = Group.active_only.participants_only.collect{ |g| [ g.code, g.id ]}
    @isr_agreements = IsrAgreement.filter( @filter_fields ).all.paginate( page: params[ :page ])
  end

  # GET /isa

  def show
  end

  # GET /isa/1/icf

  def show_icf
    @res_steps_items = @isr_agreement.res_steps.tia_items.active unless @isr_agreement.res_steps.nil?
    @val_steps_items = @isr_agreement.val_steps.tia_items.active unless @isr_agreement.val_steps.nil?
    render :icf, layout: 'plain_print'
  end

  # GET /isa/1/all

  def show_all
  end

  # GET /isr/info

  # GET /isa/1/new

  def new
    @isr_interface = IsrInterface.find( params[ :id ])
    @isr_agreement = @isr_interface.isr_agreements.build
    @workflow.initialize_current( 0 )
    set_selections( :to_create )
  end

  # get /isa/1/rev

  def new_revise
    old_agreement = @isr_agreement
    @isr_agreement = old_agreement.dup
    #@isr_agreement.belongs_to = old_agreement
    set_selections( :to_create )
    render :new
  end    

  # GET /isra/1/edit

  def edit
    set_selections( :to_update )    
  end

  # POST /isa

  def create
    @isr_agreement = IsrAgreement.new( isr_agreement_params )
    respond_to do |format|
      if @isr_agreement.save
        format.html { redirect_to @isr_agreement, notice: 'Isr agreement was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /isa/1

  def update
    respond_to do |format|
      if @isr_agreement.update(isr_agreement_params)
        format.html { redirect_to @isr_agreement, notice: 'Isr agreement was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /isa/1

  def destroy
    @isr_agreement.destroy
    respond_to do |format|
      format.html { redirect_to isr_agreements_url, notice: 'Isr agreement was successfully destroyed.' }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_isr_agreement
      @isr_agreement = IsrAgreement.find( params[ :id ])
      @isr_interface = @isr_agreement.isr_interface
      @workflow.initialize_current( 0, @isr_agreement.current_status, @isr_agreement.current_task )
      @workflow.validate_instance if $DEBUG
    end

    def set_selections( action )
      @isr_p_groups = Group.active_only.participants_only.collect{ |g| [ g.code_and_label, g.id ]}
      pg = current_user.permitted_groups( feature_identifier, action )
      @isr_l_groups = Group.permitted_groups( pg ).active_only.participants_only.collect{ |g| [ g.code_and_label, g.id ]}
      @isr_sel_states = [[ 0, 1, 3 ],[ 0, 1, 3 ]][ @isr_interface.if_status ]
      @isr_sel_states.map!{ |l| [ IsrInterface::ISR_IF_STATUS_LABELS[ l ], l ]} unless @isr_sel_states.nil?
    end

    # allow task specific views

    def confirm_or_reject
      @isr_agreement.current_task == 3
    end
    helper_method :confirm_or_reject

    # Never trust parameters from the scary internet, only allow the white list through.

    def isr_agreement_params
      params.require( :isr_agreement ).permit( :l_group_id, :p_group_id, 
        :def_text, :ia_status, :cfr_record_id, :res_steps_id, :val_steps_id, :next_status_task )
    end

    def filter_params
      params.slice( :ff_id, :ff_sts, :ff_grp, :ff_txt, :ff_wfs ).clean_up
    end

end
