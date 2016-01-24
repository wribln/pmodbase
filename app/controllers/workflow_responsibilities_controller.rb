class WorkflowResponsibilitiesController < ApplicationController
  initialize_feature FEATURE_ID_WORKFLOW_PERMISSIONS, FEATURE_ACCESS_SOME

  # GET 

  def index
    @filter_fields = filter_params
    @feature_list = Feature.with_wf.order( :label )
    if @filter_fields.empty? then
      @permissions = Permission4Flow.none
    else
      @permissions = Permission4Flow.filter( filter_params ).order( :feature_id, :workflow_id, :account_id )
    end
  end

  private

    def filter_params
      params.slice( :fr_feature ).clean_up
    end

end
