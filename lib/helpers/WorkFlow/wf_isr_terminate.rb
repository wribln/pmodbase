require_relative 'workflow'

wf = WorkFlow.new 'Terminate Interface Agreement' # permit_duplicate_status=true

wf.add_role 'IFM'
wf.add_role 'IFL'
wf.add_role 'IFP'

wf.add_initial_task 'Create Termination','IFM'
wf.add_new_task 2, 'Prepare Termination', 'IFL'
wf.add_new_task 3, 'Confirm Termination', 'IFP'
wf.add_new_task 4, 'Archive Termination', 'IFM'
wf.add_new_task 5, 'Withdraw Termination', 'IFM'
wf.add_final_task

wf.add_new_flow 1, 2, 'termination prepared'
wf.add_new_flow 2, 2, 'termination in progress'
wf.add_new_flow 2, 3, 'termination released'
wf.add_new_flow 3, 2, 'termination rejected'
wf.add_new_flow 3, 4, 'termination confirmed'
wf.add_new_flow 2, 5, 'termination to withdraw'

wf.add_new_flow 5, wf.last_task, 'closed - withdrawn'
wf.add_new_flow 4, wf.last_task, 'termination agreed'

wf.validate
wf.dump_code