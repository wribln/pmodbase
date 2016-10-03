require_relative 'workflow'

wf = WorkFlow.new 'Interface Clarification', permit_duplicate_status=true

wf.add_role 'IFM'
wf.add_role 'IFL'
wf.add_role 'IFP'

wf.add_initial_task 'Identify','IFM'

wf.add_new_task 2, 'Define', 'IFL'
wf.add_new_flow 1, 2, 'identified'

wf.add_new_task 3, 'Confirm Definition','IFP'
wf.add_new_flow 2, 3, 'definition released'
wf.add_new_flow 2, 2, 'definition in progress'
wf.add_new_flow 3, 2, 'definition rejected'

wf.add_new_task 4, 'Archive IF Status','IFM'
wf.add_new_flow 3, 4, 'definition confirmed'

wf.add_new_task 5, 'Withdraw IF','IFM'
wf.add_new_flow 2, 5, 'request withdrawal'

wf.add_final_task
wf.add_new_flow 1, wf.last_task, 'closed - not applicable'
wf.add_new_flow 5, wf.last_task, 'closed - withdrawn'

wf.validate
wf.dump_code