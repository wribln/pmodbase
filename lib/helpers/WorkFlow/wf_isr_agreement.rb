require_relative 'workflow'

wf = WorkFlow.new 'Interface Agreement', permit_duplicate_status=true

wf.add_role 'IFM'
wf.add_role 'IFL'
wf.add_role 'IFP'

wf.add_initial_task 'Create IA','IFM'

wf.add_new_task 2, 'Prepare R&V Steps', 'IFL'
wf.add_new_flow 1, 2, 'agreement prepared'
wf.add_new_flow 2, 2, 'agreement in progress'

wf.add_new_task 3, 'Confirm IA', 'IFP'
wf.add_new_flow 2, 3, 'agreement released'
wf.add_new_flow 3, 2, 'agreement rejected'

wf.add_new_task 4, 'Delete IA', 'IFM'
wf.add_new_flow 2, 4, 'request deletion'

wf.add_new_task 5, 'Archive IA Status', 'IFM'
wf.add_new_flow 3, 5, 'agreement confirmed'

wf.add_new_task 7, 'IA Agreed', 'IFM'
wf.add_new_flow 5, 7, 'agreed'

wf.add_final_task
wf.add_new_flow 4, wf.last_task, 'closed - deleted'
wf.add_new_flow 7, wf.last_task, 'closed - all R&V steps closed'

wf.validate
wf.dump_code