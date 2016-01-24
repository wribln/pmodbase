require_relative 'workflow'

wf = WorkFlow.new 'Document Life Cycle', permit_duplicate_status=true

wf.add_role 'Planner'
wf.add_role 'Author'
wf.add_role 'Doc Control'
wf.add_role 'Customer'

wf.add_initial_task 'Plan','Planner'

wf.add_new_task 2, 'Stage','Planner'
wf.add_new_flow 1, 2, 'planned'

wf.add_new_task 3, 'Prepare','Author'
wf.add_new_flow 2, 3, 'ready to start'
wf.add_new_flow 3, 3, 'in progress'

wf.add_new_task 4, 'Review','Author'
wf.add_new_flow 3, 4, 'ready to review'
wf.add_new_flow 4, 3, 'in progress'

wf.add_new_task 5, 'Prepare for Release', 'Author'
wf.add_new_flow 4, 5, 'reviewed'
wf.add_new_flow 5, 4, 'ready to review'

wf.add_new_task 6, 'Perform Submission', 'Doc Control'
wf.add_new_flow 5, 6, 'released'
wf.add_new_flow 6, 5, 'reconsider release'

wf.add_new_task 7, 'Review/Approve', 'Customer'
wf.add_new_flow 6, 7, 'submitted'

wf.add_new_task 8, 'Process Receipt', 'Doc Control'
wf.add_new_flow 7, 8, 'received'

wf.add_new_task 9, 'Process Comments', 'Author'
wf.add_new_flow 8, 9, 'B - approved with comments'
wf.add_new_flow 8, 9, 'C - rejected'

wf.add_new_flow 9, 4, 'ready for re-review'

wf.add_final_task
wf.add_new_flow 8, wf.last_task, 'closed - A - approved'
wf.add_new_flow 8, wf.last_task, 'closed - D - approval not required'
wf.add_new_flow 6, wf.last_task, 'closed - submitted for information'
wf.add_new_flow 5, wf.last_task, 'closed - submission not required'

wf.add_new_flow 1, wf.last_task, 'closed - withdrawn'
wf.add_new_flow 2, wf.last_task, 'closed - withdrawn'
wf.add_new_flow 3, wf.last_task, 'closed - withdrawn'
wf.add_new_flow 4, wf.last_task, 'closed - withdrawn'
wf.add_new_flow 5, wf.last_task, 'closed - withdrawn'

wf.add_new_flow 1, wf.last_task, 'closed - planned group complete'

wf.validate
wf.dump_code