require_relative 'workflow_params'

wfp = WorkFlowParams.new ([ 7 ])
wfp.all_params  :l_group_id, :l_owner_id, :l_deputy_id, 
                :p_group_id, :p_owner_id, :p_deputy_id,
                :def_text, 
                :cfr_record_id, :res_steps_id, :val_steps_id,
                :next_status_task

wfp.permit_none     0, 0
wfp.permit_all      0, 1
wfp.permit_all_but  0, 2, :l_group_id, :l_owner_id
wfp.permit_none     0, 3 
wfp.permit_none_but 0, 4, :next_status_task
wfp.permit_none_but 0, 5, :cfr_record_id, :res_steps_id, :val_steps_id, :next_status_task
wfp.permit_none     0, 6

wfp.validate
wfp.dump_params
 