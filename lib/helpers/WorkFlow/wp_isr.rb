require_relative 'workflow_params'

wfp = WorkFlowParams.new ([ 8 ])
wfp.all_params :if_level, :l_group_id, :p_group_id, :title, :desc, :cfr_record_id, :safety_related

wfp.permit_none 0, 0
wfp.permit_all 0, 1
wfp.permit_all_but 0, 2, :l_group_id
wfp.permit_none_but 0, 3, :current_status, :current_task
wfp.permit_none_but 0, 4, :current_status, :current_task
wfp.permit_none_but 0, 5, :current_status, :current_task
wfp.permit_all 0, 6
wfp.permit_none 0, 7

wfp.validate
wfp.dump_params
