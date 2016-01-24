require_relative 'workflow'

wf = WorkFlow.new 'Incoming RfC'

wf.add_role 'RfC Manager'
wf.add_role 'Answering Grp'
wf.add_role 'Rev/Rel Team'
wf.add_role 'Sys Eng'

wf.add_initial_task 'Receive Question', 'RfC Manager'
wf.add_new_task 2, 'Review Question', 'Rev/Rel Team'
wf.add_new_flow 1, 2, 'new'
wf.add_new_task 3, 'Prepare/Update Answer', 'Answering Grp'
wf.add_new_flow 2, 3, 'assigned'
wf.add_new_flow 3, 2, 're-evaluate'
wf.add_new_task 4, 'Review Answer', 'Sys Eng'
wf.add_new_task 5, 'Release Answer', 'Rev/Rel Team'
wf.add_new_task 6, 'Submit Answer', 'RfC Manager'
wf.add_final_task

wf.add_new_flow 3, 4, 'ready'
wf.add_new_flow 4, 3, 'update'
wf.add_new_flow 4, 5, 'reviewed'
wf.add_new_flow 5, 3, 'update'
wf.add_new_flow 5, 6, 'released'
wf.add_new_flow 6, 7, 'closed'
wf.validate

wf.dump_code