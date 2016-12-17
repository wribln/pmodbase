# workflow information for ISR

require './lib/assets/work_flow_helper.rb'
module IsrWorkFlow

    # setup workflow - call once to initialize object

    def set_workflow
      @workflow = WorkFlowHelper.new([
        [ # create IA
          [[ 0, 1 ]],
          [[ 1, 1 ],[ 2, 2 ],[ 5, 4 ]],
          [[ 3, 1 ],[ 4, 3 ]],
          [[ 7, 5 ]],
          [[ 6, 5 ]],
          [[ -1, 5 ]]
        ],
        [ # revise IA
          [[ 0, 1 ]],
          [[ 1, 1 ],[ 2, 2 ],[ 5, 4 ]],
          [[ 3, 1 ],[ 4, 3 ]],
          [[ 7, 5 ]],
          [[ 6, 5 ]],
          [[ -1, 5 ]]
        ],
        [ # terminate IA
          [[ 0, 1 ]],
          [[ 1, 1 ],[ 2, 2 ],[ 5, 4 ]],
          [[ 3, 1 ],[ 4, 3 ]],
          [[ 7, 5 ]],
          [[ 6, 5 ]],
          [[ -1, 5 ]]
        ],
        ],
        [
          [
            [ :l_group_id, :l_owner_id, :l_deputy_id, :p_group_id, :p_owner_id, :p_deputy_id, :def_text, :cfr_record_id, :res_steps_id, :val_steps_id, :next_status_task, :ia_type ],
            [                           :l_deputy_id, :p_group_id, :p_owner_id, :p_deputy_id, :def_text, :cfr_record_id, :res_steps_id, :val_steps_id, :next_status_task ],
            [ :next_status_task ],
            [ :next_status_task ],
            [ :l_group_id, :l_owner_id ],
            []
          ],
          [
            [ :l_group_id, :l_owner_id, :l_deputy_id, :p_group_id, :p_owner_id, :p_deputy_id, :def_text, :cfr_record_id, :res_steps_id, :val_steps_id, :next_status_task, :ia_type ],
            [                           :l_deputy_id, :p_group_id, :p_owner_id, :p_deputy_id, :def_text, :cfr_record_id, :res_steps_id, :val_steps_id, :next_status_task ],
            [ :next_status_task ],
            [ :next_status_task ],
            [ :l_group_id, :l_owner_id ],
            []
          ],
          [
            [ :l_group_id, :l_owner_id, :l_deputy_id, :p_group_id, :p_owner_id, :p_deputy_id, :def_text, :cfr_record_id, :res_steps_id, :val_steps_id, :next_status_task, :ia_type ],
            [                           :l_deputy_id, :p_group_id, :p_owner_id, :p_deputy_id, :def_text, :cfr_record_id, :res_steps_id, :val_steps_id, :next_status_task ],
            [ :next_status_task ],
            [ :next_status_task ],
            [ :l_group_id, :l_owner_id ],
            []
          ]
        ],
        'isr_agreements' )
      @workflow.validate_instance # if $DEBUG
    end

end