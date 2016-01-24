class FeatureResponsibilitiesController < ApplicationController
  initialize_feature FEATURE_ID_FEATURE_RESP, FEATURE_ACCESS_SOME

  # GET /

  def index
    set_final_breadcrumb( nil )
    @filter_fields = filter_params
    @feature_list = Feature.order( :label )
    if @filter_fields.empty?
      @permissions = Permission4Group.none
    else
      @permissions = Permission4Group.permission_to_modify.filter( filter_params ).order( :account_id )
    end
  end

private

  def filter_params
    params.slice( :fr_feature ).clean_up
  end

end
