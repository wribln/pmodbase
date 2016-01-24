require_relative 'workflow'

wf = WorkFlow.new 'Copy Rfc'

wf.add_role 'RfC Manager'
wf.add_role 'Rev/Rel Team'

wf.add_initial_task 'Copy RfC', 'RfC Manager'
wf.add_new_task 2, 'Review RfC', 'Rev/Rel Team'
wf.add_new_flow 1, 2, 'new'
wf.add_final_task
wf.add_new_flow 2, 3, 'closed'
wf.validate

wf.dump_code