# The purpose of this controller is to display an index of all interface agreements:
# All interface agreements will be shown - including all inactive (withdrawn, terminatted, etc.)
# This controller shall also display any statistics based on interface agreements.

require 'isr_work_flow.rb'
class IsrAgreementsController < ApplicationController
  include IsrWorkFlow

  initialize_feature FEATURE_ID_ISR_AGREEMENTS, FEATURE_ACCESS_READ

  before_action :set_workflow
  
  # GET /isa

  def index
    @filter_fields = filter_params
    @filter_states = @workflow.all_states_for_select
    @filter_groups = Group.active_only.participants_only.collect{ |g| [ g.code, g.id ]}
    @isr_agreements = IsrAgreement.filter( @filter_fields ).all.paginate( page: params[ :page ])
  end

  private

    def filter_params
      params.slice( :ff_id, :ff_sts, :ff_grp, :ff_txt, :ff_wfs ).clean_up
    end

end
