# workflow information needs to be available in both the
# IsrInterface- and the IsrAgreement-Controllers:

require './lib/assets/work_flow_helper.rb'

module IsrWorkFlow

    # setup workflow - call once to initialize object

    def set_workflow
      @workflow = WorkFlowHelper.new([
        [ # single workflow only
          [[ 0, 1 ]],
          [[ 1, 2 ],[ 10, 8 ]],
          [[ 2, 2 ],[ 3, 3 ],[ 6, 6 ],[ 8, 7 ]],
          [[ 4, 4 ],[ 9, 2 ]], # confirm, reject
          [[ 5, 5 ]],
          [[ -1, 8 ]],
          [[ 7, 2 ]],
          [[ 11, 8 ]],
          [[ -1, 8 ]]
        ],
        ],
        [
          [
            [ :if_level, :l_group_id, :p_group_id, :title, :desc, :cfr_record_id, :safety_related, :cfr_record_id, :next_status_task ],
            [ :if_level, :l_group_id, :p_group_id, :title, :desc, :cfr_record_id, :safety_related, :cfr_record_id, :next_status_task ],
            [ :p_group_id, :desc, :cfr_record_id, :next_status_task ],
            [],
            [ :next_status_task ],
            [],
            [ :if_level, :l_group_id, :p_group_id, :title, :desc, :cfr_record_id, :safety_related, :next_status_task ],
            [ :next_status_task ],
            []
          ]
        ],
        'isr_agreements' )
      @workflow.validate_instance # if $DEBUG
    end

end