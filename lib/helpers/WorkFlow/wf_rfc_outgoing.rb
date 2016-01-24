require_relative 'workflow'

wf = WorkFlow.new 'Outgoing RfC'

wf.add_role 'RfC Manager'
wf.add_role 'Asking Grp'
wf.add_role 'Answering Grp'
wf.add_role 'Rev/Rel Team'
wf.add_role 'Sys Eng'

wf.add_initial_task 'Create Question', 'Asking Grp'
wf.add_new_task 2, 'Review Question' , 'Sys Eng'
wf.add_new_flow 1, 2, 'new'
wf.add_new_task 3, 'Release Question', 'Rev/Rel Team'
wf.add_new_flow 2, 3, 'reviewed'
wf.add_new_flow 3, 3, 'hold'
wf.add_new_task 4, 'Reconsider/Update Question', 'Asking Grp'
wf.add_new_flow 3, 4, 'reconsider'
wf.add_new_flow 2, 4, 'update'
wf.add_new_flow 4, 2, 'updated'
wf.add_new_task 5, 'Submit Question', 'RfC Manager'
wf.add_new_flow 3, 5, 'released'
wf.add_new_task 6, 'Answer Question', 'Answering Grp'
wf.add_new_flow 5, 6, 'submitted'
wf.add_new_task 7, 'Receive Answer', 'RfC Manager'
wf.add_new_flow 6, 7, 'answered'
wf.add_new_task 8, 'Review Answer', 'Asking Grp'
wf.add_new_flow 7, 8, 'received'
#
# test non-reachable nodes
#
# wf.add_new_task 9, 'Test 1'
# wf.add_new_task 10, 'Test 2'
# wf.add_new_task 11, 'Test 3'
# wf.add_new_flow 8, 9, "1"
# wf.add_new_flow 9, 10, "2"
# wf.add_new_flow 10, 11, "3"
# wf.add_new_flow 11, 9, "4"
#
# test initial task with more than one outgoing flow
# (should give warning)
#
# wf.add_new_flow 0, 1, 'test'
#
wf.add_final_task
wf.add_new_flow 8, wf.last_task, 'closed - answer confirmed'
wf.add_new_flow 8, wf.last_task, 'closed - answer rejected'
wf.add_new_flow 4, wf.last_task, 'closed - question withdrawn'
wf.validate
#wf.dump

wf.dump_code