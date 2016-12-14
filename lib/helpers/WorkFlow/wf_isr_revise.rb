require_relative 'workflow'

wf = WorkFlow.new 'Revise Interface Agreement' # permit_duplicate_status=true

wf.add_role 'IFM'
wf.add_role 'IFL'
wf.add_role 'IFP'

wf.add_initial_task 'Create Revision','IFM'
wf.add_new_task 2, 'Prepare Revision', 'IFL'
wf.add_new_task 3, 'Confirm Revision', 'IFP'
wf.add_new_task 4, 'Archive Revision', 'IFM'
wf.add_new_task 5, 'Withdraw Revision', 'IFM'
wf.add_final_task

wf.add_new_flow 1, 2, 'revision prepared'
wf.add_new_flow 2, 2, 'revision in progress'
wf.add_new_flow 2, 3, 'revision released'
wf.add_new_flow 3, 2, 'revision rejected'
wf.add_new_flow 3, 4, 'revision confirmed'
wf.add_new_flow 2, 5, 'revision to withdraw'

wf.add_new_flow 5, wf.last_task, 'closed - withdrawn'
wf.add_new_flow 4, wf.last_task, 'revision agreed'

wf.validate
wf.dump_code