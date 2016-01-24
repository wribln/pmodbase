require_relative 'workflow_params'

wfp = WorkFlowParams.new ([ 8, 10, 4 ])
wfp.all_params :title, :asking_group_id, :answering_group_id, 
  :project_doc_id, :asking_group_doc_id, :answering_group_doc_id

# incoming workflow

wfp.permit_none 0, 0
wfp.permit_all  0, 1
wfp.permit_none_but 0, 2, :title, :answering_group_id
wfp.permit_none_but 0, 3, :title, :answering_group_doc_id
wfp.permit_none 0, 4
wfp.permit_none 0, 5
wfp.permit_none 0, 6
wfp.permit_none 0, 7

# outgoing workflow

wfp.permit_none 1, 0
wfp.permit_all_but 1, 1, :answering_group_doc_id
wfp.permit_none_but 1, 2, :title, :answering_group_id
wfp.permit_none_but 1, 3, :title, :answering_group_id
wfp.permit_none_but 1, 4, :title
wfp.permit_none_but 1, 5, :project_doc_id
wfp.permit_none 1, 6
wfp.permit_none_but 1, 7, :answering_group_doc_id
wfp.permit_none 1, 8
wfp.permit_none 1, 9

# copy workflow

wfp.permit_none 2, 0
wfp.permit_all  2, 1
wfp.permit_none_but  2, 2, :title
wfp.permit_none 2, 3

wfp.validate
wfp.dump_params