require_relative 'workflow_params'

wfp = WorkFlowParams.new ([ 9 ])
wfp.all_params :title

wfp.permit_all 0, 0
wfp.permit_all 0, 1
wfp.permit_all 0, 2
wfp.permit_all 0, 3
wfp.permit_all 0, 4
wfp.permit_all 0, 5
wfp.permit_all 0, 6
wfp.permit_all 0, 7
wfp.permit_all 0, 8

wfp.validate
wfp.dump_params