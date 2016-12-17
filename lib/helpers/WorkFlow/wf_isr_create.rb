require_relative 'workflow'

wf = WorkFlow.new 'Create Interface Agreement' # permit_duplicate_status=true

wf.add_role 'IFM'
wf.add_role 'IFL'
wf.add_role 'IFP'

wf.add_initial_task 'Create Agreement','IFM'
wf.add_new_task 2, 'Prepare Agreement', 'IFL'
wf.add_new_task 3, 'Confirm Agreement', 'IFP'
wf.add_new_task 4, 'Archive Agreement', 'IFM'
wf.add_new_task 5, 'Withdraw Agreement', 'IFM'
wf.add_final_task

wf.add_new_flow 1, 2, 'agreement created'
wf.add_new_flow 2, 2, 'agreement in progress'
wf.add_new_flow 2, 3, 'agreement released'
wf.add_new_flow 3, 2, 'agreement rejected'
wf.add_new_flow 3, 4, 'agreement confirmed'
wf.add_new_flow 2, 5, 'agreement to withdraw'

wf.add_new_flow 5, wf.last_task, 'closed - withdrawn'
wf.add_new_flow 4, wf.last_task, 'agreed'

wf.validate
wf.dump_code