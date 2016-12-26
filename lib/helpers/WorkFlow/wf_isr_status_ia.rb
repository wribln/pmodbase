require_relative 'workflow'

wf = WorkFlow.new 'Status Change Request' # permit_duplicate_status=true

wf.add_role 'IFM'
wf.add_role 'IFL'
wf.add_role 'IFP'

wf.add_initial_task 'Create Change Request', 'IFM'
wf.add_new_task 2, 'Confirm Change Request (IFL)', 'IFL'
wf.add_new_task 3, 'Confirm Change Request (IFP)', 'IFP'
wf.add_new_task 4, 'Archive Change Request', 'IFM'
wf.add_final_task

wf.add_new_flow 1, 2, 'change request created'
wf.add_new_flow 2, 3, 'change request confirmed (IFL)'
wf.add_new_flow 3, 4, 'change request confirmed (IFP)'
wf.add_new_flow 4, wf.last_task, 'change request completed'
wf.add_new_flow 2, 1, 'change request rejected (IFL)'
wf.add_new_flow 3, 1, 'change request rejected (IFP)'
wf.add_new_flow 1, wf.last_task, 'closed - rejected'

wf.validate
wf.dump_code