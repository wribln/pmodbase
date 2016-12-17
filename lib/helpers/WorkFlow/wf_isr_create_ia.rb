require_relative 'workflow'

wf = WorkFlow.new 'Create Interface Agreement' # permit_duplicate_status=true

wf.add_role 'IFM'
wf.add_role 'IFL'
wf.add_role 'IFP'

wf.add_initial_task 'Prepare Agreement', 'IFL'
wf.add_new_task 2, 'Confirm Agreement', 'IFP'
wf.add_new_task 3, 'Archive Agreement', 'IFM'
wf.add_new_task 4, 'Modify Agreement', 'IFM'
wf.add_final_task

wf.add_new_flow 1, 1, 'agreement in progress'
wf.add_new_flow 1, 2, 'agreement released'
wf.add_new_flow 2, 1, 'agreement rejected'
wf.add_new_flow 2, 3, 'agreement confirmed'
wf.add_new_flow 1, 4, 'agreement to modify'
wf.add_new_flow 4, 1, 'agreement modified'

wf.add_new_flow 4, wf.last_task, 'closed - withdrawn'
wf.add_new_flow 3, wf.last_task, 'agreed'

wf.validate
wf.dump_code