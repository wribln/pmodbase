# Provides methods to create and validate a simple workflow
# with a name (label) and the tasks associated with that workflow.
#
# Author::     Wilfried Römer

class WorkFlow

  # a string which provides a name or title of the workflow

  attr_reader :label

  # an array containing the WorkFlowTasks of this workflow;
  # the first (index 0) is the starting node, and is generated
  # automatically when the workflow is created; the last (the
  # terminal node) is created by the add_final_task method.

  attr_reader :task_list

  # an array containing the WorkFlowFlows of this workflow;
  # this array is only used for housekeeping purposes as all
  # flows in the workflow are also listed as incoming and
  # outgoing flows in each task

  attr_reader :flow_list

  # an array with the names of the roles; the purpose is to be able to
  # compare role assignments to the defined roles in the role_list, and
  # later to loop over all roles 

  attr_reader :role_list

  # a flag which is used internally to determine whether the workflow's
  # task list was already finalized (i.e. whether add_final_task was
  # already called)

  attr_reader :terminated

  # an array of strings containing the status label for each distinct
  # status in the workflow. The index into this array will be stored
  # with the respective flow instance

  attr_reader :status_list

  # the following flag determines how duplicate status labels are
  # handled: (false) is the default and prohibits the same label for a
  # flow to be used twice, i.e. all status labels must be unique.
  # (true) permits the same status label to be used for two flows
  # with the identical destination task such that either flow would
  # result in the same status within a workflow.

  attr_reader :permit_duplicate_status

  # validation_errors are used internally to count the number of errors
  # during workflow validation.

  @validation_errors

  # optimizations is an internal counter for optimize(_workflow)

  @optimizations

  # Initialize a new workflow with the given name;
  # also add the initial task
  #
  # [name] a string to be used a name for the workflow

  def initialize( name, permit_duplicate_status = false )
    if name.is_a? String then
      @label = name
    else
      raise ArgumentError.new( 'name must be a String' )
    end
    unless permit_duplicate_status.is_a?( TrueClass ) || permit_duplicate_status.is_a?( FalseClass ) then
      raise ArgumentError.new( 'permit_duplicate_status must be a Boolean' )
    end

    @terminated = false
    @role_list = []
    @flow_list = []
    @status_list = []
    @task_list = Array.new( 1, WorkFlowTask.new( 0, '<start new workflow>' ))
    @permit_duplicate_status = permit_duplicate_status
  end

  # Add the initial task to the workflow: 

  def add_initial_task( label, role=nil )
    raise RuntimeError.new( 'initial task already added' ) if @flow_list.count > 0
    add_the_task( 1, label, role, nil )
    copy_role( 1, 0 )
    add_new_flow( 0, 1, '<initial>' )
  end

  # Use for the given task the same role as for the other task

  def copy_role( from_task_id, to_task_id )
    raise RuntimeError.new( "from_task_id #{ from_task_id } does not exist." ) if from_task_id < 0 or from_task_id >= @task_list.count 
    raise RuntimeError.new( "to_task_id #{ to_task_id } does not exist." ) if to_task_id < 0 or to_task_id >= @task_list.count 
    @task_list[ to_task_id ].role_id = @task_list[ from_task_id ].role_id
  end

  # Add the terminal task to the workflow completing it with the terminal
  # task and by linking the initial task with the first workflow task

  def add_final_task
    if @terminated then
      raise RuntimeError.new( "workflow '#{ label }' already terminated" )
    else
      add_the_task( @task_list.count, '<workflow completed>', nil, nil )
      @terminated = true
    end
  end

  # Returns the task with the highest id

  def last_task
    @task_list.last.id
  end

  # Add a new task to the workflow
  #
  # [task_id] the (numerical) id of the task to add
  # [label] a label for the new task
  # [role] (optional) assigns a role to the task
  # [:obsolete] (optional) use this flag to mark the task obsolete,
  #   i.e. the task was used in a previous version of the workflow
  #   but is not needed in the current version; for consistency
  #   reasons, however, this task must remain in the system but will
  #   be marked '<obsolete>'

  def add_new_task( task_id, label, role=nil, obsolete=nil )
    raise RuntimeError.new( 'add_initial_task must be used first' ) unless @task_list.count > 1
    add_the_task( task_id, label, role, obsolete )
  end

  # Add a new role to the workflow
  #
  # [name] is the name (a String) of the role

  def add_role( name )
    if name.is_a? String then
      if @role_list.include? name then
        raise ArgumentError.new ("there is already a role defined with name '#{ name }'")
      else
        @role_list << name
      end
    end
  end

  # Add a new flow between two tasks to the workflow
  #
  # [from_task_id]  id of the source task
  # [to_task_id]    id of the destination task
  # [status]        status label of the flow
  # [:obsolete]     use this flag to mark the flow obsolete

  def add_new_flow( from_task_id, to_task_id, status, obsolete = nil )
    if @task_list.include? from_task_id then
      raise ArgumentError.new( "task not yet defined: #{ from_task_id }")
    elsif @task_list.include? to_task_id then
      raise ArgumentError.new( "task not yet defined: #{ to_task_id }")
    elsif !status.is_a? String then
      raise ArgumentError.new( 'status must be a String')
    elsif !obsolete.nil? and !obsolete == :obsolete then
      raise ArgumentError.new( 'obsolete flag value not recognized' ) 
    end
    i = add_new_status( status )
    f = WorkFlowFlow.new( @flow_list.count, from_task_id, to_task_id, i, obsolete == :obsolete )
    @flow_list << f
    @task_list[ from_task_id ].add_outflow f
    @task_list[ to_task_id   ].add_inflow f
    # make sure status is used correctly, i.e. it should not be the same when target is not
    # the same (@permit_duplicate_status), or another status has the same text
    @flow_list.each do |fl|
      if fl.id != f.id and @status_list[ fl.status_id ] == @status_list[ f.status_id ] then
        if @permit_duplicate_status
          if fl.target_task_id != f.target_task_id then
            puts
            puts ">>> Warning: new #{ f.to_s }"
            puts ">>>          has same status '#{ status_list[ f.status_id ]}'"
            puts ">>>          but a different target as #{ fl.to_s }"
          end
        else
          puts
          puts ">>> Warning: new #{f.to_s}"
          puts ">>>          uses the same status '#{ status_list[ f.status_id ]}' as"
          puts ">>>          previous #{ fl.to_s }"
        end
      end
    end
   end

  # Provide a listing of the workflow

  def dump
    puts
    puts "WorkFlow '#{ @label }' consists of the following tasks:"
    @task_list.each{ |t| t.dump }
    puts
  end

  # Optimizes the current version of the workflow

  def optimize
    raise Runtimeerror.new( 'only terminated workflows can be validated') unless @terminated
    @optimizations = 0
    puts
    puts "Start optimization of Workflow '#{ label }'"
    optimize_workflow
    puts "No of optimized transition states: #{ @optimizations }"
    puts
  end

  # Validates the current version of the workflow

  def validate
    raise RuntimeError.new( 'only terminated workflows can be validated' ) unless @terminated
    @validation_errors = 0
    puts
    puts "Start Validation of WorkFlow '#{ label }"
    validate_workflow
    validate_reachability
    puts "Validation of WorkFlow '#{ label }' #{
      @validation_errors > 0 ? 'FAILED' : 'successfully completed' }."
    puts
  end

  # Provide code snippets to include in an application using this workflow
  # [type_switch] 0 - separate arrays for flows and tasks
  #               1 - array with [ flow, task ] pairs

  def dump_code( type_switch = 1 )
    wf_name = label.downcase.gsub(/ /,'_')
    puts
    puts "Code Snippets for #{ label }:"
    puts
    puts "Number of tasks:  #{ @task_list.count }"
    puts "Number of flows:  #{ @flow_list.count }"
    puts "Number of states: #{ @status_list.count }"
    puts
    puts "List of Task Labels (I18n format):"
    puts 
    puts "  workflow:"
    puts "    w00:"
    puts "      label:\t'#{ label }'"
    puts "      tasks:"
    @task_list.each_with_index do |t,i|
    next if t.nil?
    puts "        #{ sprintf('t%02d',i)}:\t'#{ t.label }#{ ' <obsolete>' if t.obsolete }'"
    end
    puts "      states:"
    obsolete_marker = Array.new( status_list.count, false )
    @flow_list.each{ |f| obsolete_marker[ f.status_id ] |= f.obsolete }
    @status_list.each_with_index do |l,i|
      puts "        #{ sprintf('s%02d',i )}:\t'#{ status_list[ i ]}#{ ' <obsolete>' if obsolete_marker[ i ] }'"
    end
    puts
    puts "Transition Structure:"
    puts
    printf "@#{ wf_name } = WorkFlowHelper.new(["

    case type_switch
      when 0
        sep = "\n"
        @task_list.each do |t|
          flows = t.outflows.collect{ |f| f.id }.join(',')
          tasks = t.outflows.collect{ |f| f.target_task_id }.join(',')
          printf "%s  [[%s],[%s]]", sep, flows, tasks
          sep = ",\n"
        end
      when 1
        sep = "\n"
        flow_tasks = ''
        @task_list[0...-1].each do |t|
          next if t.nil?
          flow_tasks = t.outflows.collect{ |f| "[ %d, %d ]" % [ f.status_id, f.target_task_id ]}.join(',')
          printf "%s [%s]", sep, flow_tasks
          sep = ",\n"
        end
        printf "%s [[ -1, %d ]]\n", sep, @task_list.length - 1
    end

    puts "])"
    puts

    # list all roles with tasks for which they are responsible

    puts 'Responsibilities:'
    puts
    @role_list.each_with_index do |r,i|
      s = sprintf "%-20s", @role_list[ i ]
      sep = ''
      @task_list[0...-1].each_with_index do |t,j|
        next if t.nil?
        if t.role_id == i then
          s += sep + j.to_s
          sep = ','
        end
      end
      puts s
    end
    puts

    # better warn the user if there were any validation errors ...

    if @validation_errors > 0 then
      puts ">>> Errors detected during validation - check full report above. <<<"
      puts
    end

  end

  protected

  # Add a new status label to the status_list: if @permit_duplicate_status is set,
  # return the index of the existing label - if it exists, else create new label.
  # [label]         the string to be used as status label

  def add_new_status( label )
    i = status_list.find_index( label )
    if i.nil? or !permit_duplicate_status then
      i = status_list.count
      status_list[ i ] = label
    end
    return i
  end

  # Optimize workflow will perform the following:
  # * (stub)

  def optimize_workflow
  end  

  # The following validations will be performed for each task in the workflow:
  # * no undefined tasks must exists, i.e. all tasks in the task_list
  #   must be defined. This is the responsibility of the user adding
  #   the tasks to the workflow.
  # * the id of each task must match the index in the @task_list. This
  #   should always be true as this is automatically ensured.
  # * all tasks but the initial task must have at least one incoming flow:
  #   if this would not be the case, that task could not be reached from
  #   other tasks.
  # * all tasks but the terminal task must have at least one outgoing flow:
  #   tasks with no outgoing flow are terminal tasks, and we allow only a
  #   single terminal task, i.e. all flows through the workflow must end
  #   at the same terminal task.
  # * task labels must be unique to avoid misunderstandings.
  # * any outgoing flow must have a corresponding incoming flow in the
  #   target node.
  # * any incoming flow must have a corresponding outgoing flow in the
  #   source node.
  # * any obsolete task must only have obsolete incoming and outgoing flows
  # * if the inital task has more than one outgoing flow, output a warning
  #   as this might require some extra programming: the internal initial
  #   state then cannot be set automatically to the initial external state -
  #   (controller) logic must be implemented to ensure determine which 
  #   initial external status should be selected for the start of the
  #   workflow.
  # For each flow in the workflow, the following will be checked
  # * no undefined flows must exist, i.e. all flows in the flow_list
  #   must be defined. This should always pass as the list is fully managed
  #   within the class.
  # * the id of each flow must match the index in the @flow_list. This
  #   should always be true as this is automatically ensured.
  # * if no duplicate states are permitted (@permit_duplicate_status=false)
  #   each flow must have a unique status label

  def validate_workflow
    e = 0
    status_usage = Array.new( flow_list.count, 0 )
    obsolete_use = Array.new( flow_list.count, 0 )
    @flow_list.each_with_index do |f,i|
      # count usage
      if f.status_id < 0 or f.status_id >= status_usage.count then
        puts "  status_id outside range: (0,#{flow_list.count})"
        e += 1
      else
        status_usage[ f.status_id ] += 1
        obsolete_use[ f.status_id ] += 1 if f.obsolete
      end
      # there must be no gaps = undefined flows in the flow_list
      if f.nil? then
        puts "  Missing Flow definition with id = #{ i }"
        e += 1
      else
        # flow id must match index in flow_list
        if i != f.id then
          puts "  Mismatch of flow_list index #{ i } and flow.id #{ f.id } - they must be identical."
          e += 1
        end
      end
    end
    # check number of status labels
    status_usage_sum = status_usage.reduce(0,:+)
    if status_usage_sum != flow_list.count then
      puts "  Number of status labels (#{ status_usage_sum }) does not correspond to number of flows (#{ flow_list.count })"
      e += 1
    end
    if permit_duplicate_status then
      if status_list.count > flow_list.count then
        puts "  Number of status labels (#{ status_list.count }) must be <= number of flows (#{ flow_list.count })"
        e += 1
      end
    else
      if status_list.count != flow_list.count then
        puts "  Number of status labels (#{ status_list.count }) must be == number of flows (#{ flow_list.count })"
        e += 1
      end
    end
    status_usage.each_with_index do |u,i| 
      if obsolete_use[ i ] > 0 and obsolete_use[ i ] != u then
        puts "  Status '#{ status_list[ i ]}' must be obsolete for ALL flows or NONE:\n" + \
             "  Remove single obsolete flows manually instead of marking them as obsolete"
        e += 1
      end
    end
    # check tasks
    @task_list.each_with_index do |t,i|
      # there must be no gaps = undefined tasks in the task_list
      if t.nil? then
        puts "  Missing Task definition with id = #{ i }"
        e += 1
      else
        # task id must match index in task_list
        if i != t.id then
          puts "  Mismatch of task_list index #{ i } and task.id #{ t.id } - they must be identical."
          e += 1
        end
        # all tasks but the initial task must have incoming flows
        if t == @task_list.first then
          if !t.inflows.empty? then
            puts "  Initial Task must not have any incoming flows."
            e += 1
          end
        else
          if t.inflows.empty? then
            puts "  Task #{ t.id } '#{ t.label }' cannot be reached: no incoming flows."
            e += 1
          end
        end
        # all tasks but the terminal task must have outgoing flows
        if t == @task_list.last then
          if !t.outflows.empty? then
            puts "  Terminal Task must not have any outgoing flows."
            e += 1
          end
        else
          if t.outflows.empty? then
            puts "  Task #{ t.id } '#{ t.label }' has no outgoing flows but is not the Terminal Task."
            e += 1
          end
        end
        # task label must be unique
        @task_list[ i+1 .. -1 ].each do |s|
          next if s.nil?
          if s.label == t.label then
            puts "  Identical label for tasks #{ t.id } and { s.id }: '#{ t.label }'"
            e += 1
          end
        end
        t.outflows.each do |fo|
          # flow must be in flow_list
          if fo != @flow_list[ fo.id ] then
            puts "  Outgoing flow from #{ t.id } with status '#{ fo.status }' not found in worklist's flow_list."
            e += 1
          end
          # outgoing flow must have a corresponding incoming flow - this should always pass
          if !@task_list[ fo.target_task_id ].inflows.include?( fo ) then
            puts "  Outgoing flow from #{ t.id } with status '#{ status_list[ fo.status_id ]}' is not incoming flow to #{ fo.target_task_id }"
            e += 1
          end
          # check if obsolete task has non-obsolete outgoing flow
          if t.obsolete and !fo.obsolete then
            puts "  Obsolete task #{ t.id } has non-obsolete outgoing flow\n"\
                 "    with status '#{ fo.status }' to task ##{ fo.target_task_id}"
            e += 1
          end
        end
        t.inflows.each do |fi|
          # flow must be in flow_list
          if fi != @flow_list[ fi.id ] then
            puts "  Incoming flow to #{ t.id } with status '#{ status_list[ fi.status ]}' not found in worklist's flow_list."
            e += 1
          end
          # incoming flow must have a corresponding outgoing flow - this should always pass
          if !@task_list[ fi.source_task_id ].outflows.include?( fi ) then
            puts "  Incoming flow to #{ t.id } with status '#{ fi.status }' is not outgoing flow from #{ fi.source_task_id}"
            e += 1
          end
          # check if obsolete task has non-obsolete incoming flow
          if t.obsolete and !fi.obsolete then
            puts "  Obsolete task #{ t.id } has non-obsolete incoming flow\n"\
                 "    with status '#{ fi.status }' from task ##{ fi.source_task_id}"
            e += 1
          end
        end
      end
    end
    # test initial task
    if @task_list.first.outflows.length > 1 then
      puts
      puts ">>> Warning: Initial Task has more than one outgoing flow:"
      @task_list.first.outflows.each do |f|
        puts ">>>          #{f.to_s}"
      end
      puts
    end
    # summarize
    puts "  Validation of Tasks: #{ e > 0 ? 'failed' : 'OK' }"
    @validation_errors += e
  end

  # Ensure that each node can reach a path to the terminal node

  def validate_reachability
    node_has_path_to_terminal_node = Array.new( @task_list.size, false )
    work_stack = []
    work_stack.push @task_list.last # is always non-obsolete!
    begin
      t = work_stack.pop
      next if t.obsolete
      node_has_path_to_terminal_node[ t.id ] = true
      t.inflows.each do |f|
        next if f.obsolete
        if !node_has_path_to_terminal_node[ f.source_task_id ] then
          work_stack.push @task_list[ f.source_task_id ]
        end
      end
    end until work_stack.empty?
    e = 0
    node_has_path_to_terminal_node.each_with_index do |n,i|
      next if @task_list[ i ].nil?
      if !n and !@task_list[ i ].obsolete then
        puts "  task ##{ i } '#{ @task_list[i].label }' has no path to terminal task"
        e += 1
      end
    end
    puts "  Validation of Reachability: #{ e > 0 ? 'failed' : 'OK' }"
    @validation_errors += e
  end

  # Private helper function performing the actual adding of a task;
  # the parameters are the same as for add_new_task:
  # [task_id] the (numerical) id of the task to add
  # [label] a label for the new task
  # [role] (optional) assigns a role to the task
  # [:obsolete] (optional) use this flag to mark the task obsolete

  def add_the_task( task_id, label, role, obsolete )
    raise RuntimeError.new( 'workflow already terminated' ) if @terminated
    if role.nil? then
      role_id = nil
    else
      raise ArgumentError.new( 'role must be a String' ) unless role.is_a? String
      role_id = @role_list.index( role )
      raise ArgumentError.new( "undefined role: '#{ role }'") if role_id.nil?
    end
    if !obsolete.nil? and !obsolete == :obsolete then
      raise ArgumentError.new( 'obsolete flag value not recognized' ) 
    end
    if @task_list[ task_id ].nil?
      @task_list[ task_id ] = WorkFlowTask.new( task_id, label, role_id, obsolete == :obsolete )
    else
      raise ArgumentError.new( "task ##{ task_id } is already defined in workflow")
    end
  end

  # add the specified task to the workflow
  # [task] must not be nil and must not yet be defined in the workflow with 
  #        the given id

  def add_task( task )
    raise ArgumentError.new( 'task must be a WorkFlowTask') unless task.is_a? WorkFlowTask
    if @task_list[ task.id ].nil?
      @task_list[ task.id ] = task
    else
      raise ArgumentError.new( "task ##{ task.id } is already defined in workflow")
    end
  end

# A WorkFlowTask is an atomic activity with a the associated WorkFlow.
# Within a workflow, each task has a unique id. A descriptive name (label)
# is used to describe the task.
#
# This class is intended for exclusive use within the WorkFlow class.

class WorkFlowTask

  # the id of the task: must be unique and consecutive, i.e. in a completed
  # workflow, no two tasks must use the same id, and the list of ids must not
  # have any gaps

  attr_reader :id

  # the label contains a descriptive name for the task

  attr_reader :label

  # all outgoing flows are kept in an array

  attr_reader :outflows

  # all incoming flows are kept in an array

  attr_reader :inflows

  # the id of the main responsible role

  attr_accessor :role_id

  # flags whether this task should be ignored for any calculations and
  # validations; all links to and from this task must also be obsolete

  attr_reader :obsolete

  # Create a new task with the given attributes:
  # [task_id] a unique integer
  # [label] the descriptive name of the task
  # [role] (optional) the role which would be mainly responsible for this task
  # [obsolete] can be set to true if this task is only added to the workflow
  #            for compatibility reasons with previous versions of the
  #            workflow

  def initialize( task_id, label, role_id=nil, obsolete=false )
    @inflows = []
    @outflows = []
    @obsolete = obsolete
    @id = task_id
    @role_id = role_id
    @label = label
    validate
  end

  # Add anothoer outgoing flow to the task
  # [flow] is the WorkFlowFlow to be added to the list of outgoing flows from
  #        the current task

  def add_outflow( flow )
    if flow.is_a? WorkFlowFlow then
      @outflows << flow
    else
      raise ArgumentError.new( 'flow must be a WorkFlowFlow' )
    end
  end

  # Add another incoming flow to the task
  # [flow] is the WorkFlowFlow to be added to the list of incoming flows to
  #        the current task

  def add_inflow( flow )
    if flow.is_a? WorkFlowFlow then
      @inflows << flow
    else
      raise ArgumentError.new( 'flow must be a WorkflowFlow' )
    end
  end

  # Perform internal validation of this task's attributes
 
  def validate
    unless TrueClass === @obsolete or FalseClass === @obsolete then
      raise RuntimeError.new( 'task validation failed: obsolete must be true or false ')
    end
    unless @id.is_a? Integer then
      raise RuntimeError.new( 'task validation failed: id must be an Integer' )
    end
    unless @role_id.is_a? Integer or @role_id.nil? then
      raise RuntimeError.new( 'task validation failed: role_id must be nil or an Integer' )
    end
    unless @label.is_a? String then
      raise RuntimeError.new( 'task validation failed: label must be a String' )
    end
    unless @inflows.is_a? Array then
      raise RuntimeError.new( 'task validation failed: incoming flows must be an Array' )
    else
      @inflows.each do |f|
        unless f.is_a? WorkFlowFlow
          raise RuntimeError.new( 'task validation failed: an incoming flow is not a WorkFlowFlow' )
        end
      end
    end
    unless @outflows.is_a? Array then
      raise RuntimeError.new( 'task validation failed: outgoing flows must be an Array' )
    else
      @outflows.each do |f|
        unless f.is_a? WorkFlowFlow
          raise RuntimeError.new( 'task validation failed: an outgoing flow is not a WorkFlowFlow' )
        end
      end
    end
  end

  # Provide a listing of the task

  def dump
    unless @obsolete then
      puts "  WorkFlow task ##{ @id } '#{ @label }':"
      puts "    #{ @inflows.count{ |f| !f.obsolete }} incoming flows:"
      @inflows.each_with_index do |f,i|
        puts "    (#{ i }) #{ f.dump_info_from }" unless f.obsolete
      end
      puts "    #{ @outflows.count{ |f| !f.obsolete }} outgoing flows:"
      @outflows.each_with_index do |f,i| 
        puts "    (#{ i }) #{ f.dump_info_to }" unless f.obsolete
      end
    end
  end

end

# Each flow (vertix/transition) in a workflow is represented by this
# object: it provides the link between the source and and target task, and the
# associated status for workflow instances on that path.
#
# This class is intended for exclusive use within the WorkFlow class.

class WorkFlowFlow

  # a unique id for the flow

  attr_accessor :id

  # the id (i.e. the index into the WorkFlow's task_list) of the source task
  
  attr_reader :source_task_id

  # the id (i.e. the index into the WorkFlow's task_list) of the target task

  attr_reader :target_task_id

  # the status of workflow instances on this path expressed as id into the
  # list of status labels

  attr_reader :status_id

  # flags whether this flow should be ignored for any calculations and
  # validations

  attr_reader :obsolete

  # Create new flow with all required information:
  # [id] an id for this flow (actually generated from the index into the
  #      workflow's flow_list)
  # [source_task_id] the id of the task where this flow originates from
  # [target_task_id] the id of the task which could be the possible next
  # [status] is the status text associated with this flow
  # [obsolete] can be set to true if this flow is only added to document
  #            a previously used flow which is not used anymore

  def initialize( id, source_task_id, target_task_id, status_id, obsolete = false )
    @id = id
    @source_task_id = source_task_id
    @target_task_id = target_task_id
    @status_id = status_id
    @obsolete = obsolete
    validate
  end

  # output data for messages to terminal:

  def to_s
    "workflow #{ id } from task #{ source_task_id } to task #{ target_task_id } with status <#{ status_id }>"
  end 

  # Provide a dump information for an incoming flow

  def dump_info_from
    "from task #{ source_task_id } as '#{ status_id }'#{ ' >obsolete<' if obsolete }"
  end
  
  # Provide a dump information for an outgoing flow

  def dump_info_to
    "to task #{ target_task_id } as '#{ status }'#{ ' >obsolete<' if obsolete }"
  end 

  # Validate all attributes of flow

  def validate
    unless @id.is_a? Integer then
      raise RuntimeError.new( 'flow validation failed: id must be an Integer' )
    end
    unless TrueClass === @obsolete || FalseClass === @obsolete then
      puts "obsolete: #{ @obsolete.class }"
      raise RuntimeError.new( 'flow validation failed: obsolete must be true or false ')
    end
    unless @target_task_id.is_a? Integer then
      raise RuntimeError.new( 'flow validation failed: target_task_id must be an Integer' )
    end
    unless @source_task_id.is_a? Integer then
      raise RuntimeError.new( 'flow validation failed: target_task_id must be an Integer' )
    end
    unless @status_id.is_a? Integer then
      raise RuntimeError.new( 'flow validation failed: status_id must be an Integer' )
    end
  end

end

end

