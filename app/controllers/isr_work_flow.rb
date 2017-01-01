# workflow information for ISR

require './lib/assets/work_flow_helper.rb'
module IsrWorkFlow

    # setup workflow - call once to initialize object

    def set_workflow
      wf01 = [
          [[ 0, 1 ]],
          [[ 1, 2 ]],
          [[ 2, 2 ],[ 3, 3 ],[ 4, 5 ]],
          [[ 5, 4 ],[ 6, 2 ]],
          [[ 8, 6 ]],
          [[ 7, 2 ],[ 9, 6 ]],
          [[ -1, 6 ]]
        ]
      wf234 = [
          [[ 0, 1 ]],
          [[ 1, 2 ],[ 7, 5 ]],
          [[ 2, 3 ],[ 5, 1 ]],
          [[ 3, 4 ],[ 6, 1 ]],
          [[ 4, 5 ]],
          [[ -1, 5 ]]
        ]
      wp01 = [
          [ :l_group_id, :l_owner_id, :l_deputy_id, :p_group_id, :p_owner_id, :p_deputy_id, :def_text, :cfr_record_id, :res_steps_req, :val_steps_req, :ia_type, :based_on_id ],
          [ :l_group_id, :l_owner_id, :l_deputy_id, :p_group_id, :p_owner_id, :p_deputy_id, :def_text, :cfr_record_id, :res_steps_req, :val_steps_req ],
          [                           :l_deputy_id, :p_group_id, :p_owner_id, :p_deputy_id, :def_text, :cfr_record_id, :res_steps_req, :val_steps_req ],
          [],
          [],
          [ :l_group_id, :l_owner_id ],
          []
        ]
      wp234 = [
          [ :l_group_id, :l_owner_id, :l_deputy_id, :p_group_id, :p_owner_id, :p_deputy_id, :def_text, :cfr_record_id, :res_steps_req, :val_steps_req, :ia_type, :based_on_id ],
          [ :l_group_id, :l_owner_id, :l_deputy_id, :p_group_id, :p_owner_id, :p_deputy_id, :def_text, :cfr_record_id, :res_steps_req, :val_steps_req ],
          [],
          [],
          [],
          []
        ]

      @workflow = WorkFlowHelper.new([
        wf01,
        wf01,
        wf234,
        wf234,
        wf234
        ],
        [
        wp01,
        wp01,
        wp234,
        wp234,
        wp234
        ],
        'isr_agreements' )
      @workflow.validate_instance # if $DEBUG
    end

end