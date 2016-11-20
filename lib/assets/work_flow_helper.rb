# supports workflow handling by providing helper functions
#
# the scope for the I18n library to be used is computed using 
# the controller's class name, followed by the string 'workflows' and then
# 'w<nn>' for the workflow, 'label' for the workflow's name, 
# 's<nn>' for the status, and 't<nn>' for the task labels.
#
# Author::     Wilfried Römer

class WorkFlowHelper

  # The following array structure describes the possible task transitions 
  # for each type of workflow (i.e. level 1 of the array); for each task,
  # a list of possible next status and task pairs (level 2) is specified
  # as a two-dimensiona array (level 3).
  #
  # The number of entries in the level 1 array is the number of workflows
  # defined in this structure, the number of entries in the respective level 2
  # arrays are the possible status transitions; on level 3, there are always
  # two elements in the array: the first being the status, the second the
  # task.

  attr_reader :wf_transitions

  # This array structure contains the attributes per type of workflow and
  # per task which are permitted to be modified (provided the user has the
  # respective access rights): The array is two dimensional, the first
  # corresponding to the level 1 of the @wf_transition structure, the
  # second has one entry per task with the entry being an array with all
  # permitted attributes.

  attr_reader :wf_permits

  # the workflow index is used to differentiate between the different 
  # workflows types specified in the transitions structure; this can be nil
  # when this information is not required.

  attr_reader :wf_current_index
  attr_reader :wf_current_status
  attr_reader :wf_current_task

  # hold here the new, updated status and task information: this must not
  # be used for any function referring to the current status and task!

  attr_reader :wf_updated_status
  attr_reader :wf_updated_task

  # provides the prefix for the I18n scope

  attr_reader :i18n_prefix

  # create instance with the workflows' information for this controller

  def initialize( wf_transitions, wf_permits, i18n_prefix )
    @wf_transitions = wf_transitions
    @wf_permits = wf_permits
    @i18n_prefix = i18n_prefix
    @wf_current_index = nil
    @wf_current_status = nil
    @wf_current_task = nil
    @wf_updated_status = nil
    @wf_updated_task = nil
  end

  # helper method allowing to set all other instance variables at the same
  # time

  def initialize_current( index, status = 0, task = 0 )
    @wf_current_index = index
    @wf_current_status = status
    @wf_current_task = task
  end

  # helper methods to allow iterations

  def no_of_workflows
    @wf_transitions.size
  end

  # return the number of tasks in the workflow

  def no_of_tasks( w )
    @wf_transitions[ w ].size
  end

  # return the highest status number used in the workflow
  # plus 1 for the initial, 0 state

  def no_of_states( w )
    n = 0
    @wf_transitions[ w ].each do |l1|
      l1.each do |l2|
        n = ( l2[ 0 ] > n ) ? l2[ 0 ] : n
      end
    end
    return n + 1
  end

  def no_of_outgoing_flows( t, w )
    @wf_transitions[ w ][ t ].size
  end

  # validate the current status of this instance (could/should be used for
  # debugging and testing)

  def validate_instance

    # check level 1 structure of wf_transitions: 

    unless @wf_transitions.kind_of?( Array ) then
      raise ArgumentError.new( 'wf_transitions must be an Array' )
    end
    unless @wf_transitions.length > 0 then
      raise ArgumentError.new( 'wf_transitions must not be empty' )
    end

    # check each level 2 structure per type

    @wf_transitions.each_with_index do | wft2, l1 |
      unless wft2.kind_of?( Array )then
        raise ArgumentError.new( "wf_transitions[ #{l1} ] must be an Array" )
      end
      unless wft2.length > 0 then
        raise ArgumentError.new( "wf_transitions[ #{l1} ] must not be empty" )
      end

      # check each level 3 structure per tasks per type

      wft2.each_with_index do | wft3, l2 |
        unless wft3.kind_of?( Array )then
          raise ArgumentError.new( "wf_transitions[ #{l1} ][ #{l2} ] must be an Array" )
        end
        unless wft3.length > 0 then
          raise ArgumentError.new( "wf_transitions[ #{l1} ][ #{l2} ] must not be empty" )
        end

        # check each level 4 structure per possible next steps per task per type

        wft3.each_with_index do | wft4, l3 |
          unless wft4.kind_of?( Array )then
            raise ArgumentError.new( "wf_transitions[ #{l1} ][ #{l2} ][ #{l3} ] must be an Array" )
          end
          unless wft4.length == 2 then
            raise ArgumentError.new( "wf_transitions[ #{l1} ][ #{l2} ][ #{l3} ] must be an array with length = 2" )
          end
          wft4.each_with_index do | v, l4 |
            unless v.kind_of?( Integer ) then
              raise ArgumentError.new( "wf_transitions[ #{l1} ][ #{l2} ][ #{l3} ][ #{l4} ] must be an Integer" )
            end
          end
          # status must be >= 0 unless it is the last one
          unless wft3 = wft2.last then
            unless wft4[ 0 ] >= 0 then
              raise ArgumentError.new( "wf_transitions[ #{l1} ][ #{l2} ][ #{l3} ][ 0 ] = #{ wft4[ 0 ]} must be >= 0" )
            end
          end            
          # task index must be within limits
          unless wft4[ 1 ] >= 0 then
            raise ArgumentError.new( "wf_transitions[ #{l1} ][ #{l2} ][ #{l3} ][ 1 ] = #{ wft4[ 1 ]} must be >= 0" )
          end
          unless wft4[ 1 ] < wft2.length then
            raise ArgumentError.new( "wf_transitions[ #{l1} ][ #{l2} ][ #{l3} ][ 1 ] = #{ wft4[ 1 ]} must be < #{ wft2.length }" )
          end
        end
      end
      # last status must be -1
      wft2.last.each_with_index do | wft4, l3 |
        unless wft4[ 0 ] == -1 then
          raise ArgumentError.new( "wf_transitions[ #{l1} ].last[ #{l3} ] status is #{ wft4[ 0 ] } but must be -1" ) 
        end
        # last task must be pointing to itself
        unless wft4[ 1 ] == wft2.length - 1 then
          raise ArgumentError.new( "wf_transitions[ #{l1} ].last[ #{l3} ] last task is #{ wft4[ 1 ]} but must be #{ wft2.length - 1 }" )
        end
      end
    end

    # i18n_prefix must be a string ...

    unless i18n_prefix.kind_of?( String )then
      raise ArgumentError.new( 'i18n_prefix must be a String' )
    end

    # check instance variables - when defined

    unless @wf_current_index.nil? then
      unless @wf_current_index.kind_of?( Integer )then
        raise ArgumentError.new( 'wf_current_index must be an Integer' )
      end
      unless @wf_current_index >= 0  and @wf_current_index < @wf_transitions.length then
        raise ArgumentError.new( "wf_current_index outside of range ( 0...#{( @wf_transitions.length - 1)} )")
      end

      unless @wf_current_task.nil? then
        unless @wf_current_task.kind_of?( Integer )then
          raise ArgumentError.new( 'wf_current_task must be an Integer' )
        end
        unless @wf_current_task >= 0 and @wf_current_task < @wf_transitions[ @wf_current_index ].length then
          raise ArgumentError.new( "wf_current_task outside of range ( 0...#{( @wf_transitions[ @wf_current_index ].length - 1 )})")
        end
      end
    end

    # check wf_permits - if specified / not nil

    unless @wf_permits.nil?

      unless @wf_permits.kind_of?( Array ) then
        raise ArgumentError.new( 'wf_permits must be an Array' )
      end
  
      # first level length must be same as in wf_transitions
  
      unless @wf_permits.length == @wf_transitions.length then
        raise ArgumentError.new( "wf_permits, level 1 must have same length (#{ @wf_permits.length }) as wf_transitions (#{ @wf_transitions.length })" )
      end
  
      # check each second level entry: must have same length as the
      # corresponding wf_transitions, i.e. must map to the same tasks
  
      @wf_permits.each_with_index do | wfc2, l1 |
  
        # level 2 must be an array with length = number of tasks
  
        unless wfc2.kind_of?( Array ) then
          raise ArgumentError.new( "wf_permits[ #{ l1 } ] must be an Array" )
        end
  
        n_tasks = @wf_transitions[ l1 ].length
        unless wfc2.length == n_tasks then
          raise ArgumentError.new( "wf_permits[ #{ l1 } ] must be same length (#{ wfc2.length }) as corresponding @wf_transitions (#{ n_tasks })" )
        end
  
        wfc2.each_with_index do | wfc3, l2 |
          look_for_array_of_symbols_or_hashes( wfc3, "wf_permits[ #{ l1 } ][ #{ l2 } ]" )
        end
      
      end
      
    end

    return true

  end

  def look_for_array_of_symbols_or_hashes( item, item_string )

    unless item.kind_of?( Array )
      raise ArgumentError.new( item_string + " must be an Array" )
    end

    item.each_with_index do | sub_item, sub_level |
      case sub_item
        when Symbol then # ok
        when Hash then 
          sub_item.each do | key, value |
            look_for_array_of_symbols_or_hashes( value, item_string + "[ #{ key } ]")
          end
        else
          raise ArgumentError.new( item_string + "[ #{ sub_level } ] must be a Symbol or a Hash" )
      end
    end

  end
  private :look_for_array_of_symbols_or_hashes

  # determine whether a status change is possible at this time (this helps 
  # in views to display either a selection or a readonly field)

  def status_change_possible?
    current_options = @wf_transitions[ @wf_current_index ][ @wf_current_task ]
    ( current_options.length > 1 ) or (
    ( current_options[ 0 ][ 1 ] != @wf_current_task ) and 
    ( current_options[ 0 ][ 0 ] != -1 ))
  end

  # prepare a collection of labels 'status / task' for list boxes in views
  # include current status if to allow the user to remain at the current 
  # settings; avoid duplicates which might irritate the user

  def next_status_task_labels_for_select
    label_collection = [[ status_task_label, 0 ]]
    @wf_transitions[ @wf_current_index ][ @wf_current_task ].each_with_index do| nst, index |
      label_collection << [ status_task_label( nst[ 0 ], nst[ 1 ] ), index + 1 ] unless nst[ 0 ] < 0
    end
    return label_collection.uniq{ |l| l.first }
  end

  # prepare labels with sequence numbers using standard utilities

  def next_status_task_label_with_id( i, t, w )
    status_task_label_with_id(
      @wf_transitions[ w ][ t ][ i ][ 0 ],
      @wf_transitions[ w ][ t ][ i ][ 1 ], w )
  end

  # return a collection of all possible workflows;
  # the parameter allowed_wf - if given - contains an array with permitted workflows,
  # if this parameter is nil, all workflows will be listed

  def workflow_labels_for_select( allowed_wf = nil )
    label_collection = []
    no_of_workflows.times do | index |
      label_collection << [ workflow_label( index ), index ] if allowed_wf.nil? || allowed_wf.include?( index )
    end
    return label_collection
  end

  # return a collection of all possible states
  # wf gives the workflow to show, else all

  def all_states_for_select( wf = nil )
    label_collection = []
    if wf.nil? then
      no_of_workflows.times do | w |
        label_collection << [ "#{ workflow_label( w )}...", "#{ w }" ]
        no_of_states( w ).times do | s |
          label_collection << [ "...#{ status_label( s, w )}", "#{ w },#{ s }" ]
        end
      end
    else
      no_of_states( wf ).times do | s |
        label_collection << [ "#{ status_label( s, wf )}", "#{ s }" ]
      end
    end
    label_collection
  end

  # set the next task and status based on the index of the array created by
  # next_status_task_labels_for_select; note that this is 0 if there is no
  # status change, and off by 1 for any status change...

  def update_status_task( i )
    if i > 0 then
      updated_status_task = @wf_transitions[ @wf_current_index ][ @wf_current_task ][ i - 1 ] 
      @wf_updated_status = updated_status_task[ 0 ] unless updated_status_task[ 0 ] < 0
      @wf_updated_task =   updated_status_task[ 1 ]
    else
      @wf_updated_status = @wf_current_status
      @wf_updated_task = @wf_current_task      
    end
  end

  # retrieve the label of the workflow: use either without parameter
  # (which causes the object's wf_current_index to be used), or with
  # a specific wf_current_index

  def workflow_label( w = nil )
    I18n.t( sprintf( '%s.workflows.w%02d.label', @i18n_prefix, w || @wf_current_index ))
  end

  # return the label with the sequence number like records with ID

  def workflow_label_with_id( w = nil )
    ApplicationModel::some_text_and_id( workflow_label( w ), w )
  end

  # retrieve the label for the given status: use either with a single
  # parameter (which causes the object's wf_current_index to be used),
  # or with a specific wf_current_index

  def status_label( s = nil, w = nil )
    I18n.t( sprintf( '%s.workflows.w%02d.states.s%02d', @i18n_prefix, w || @wf_current_index, s || @wf_current_status ))
  end

  # return the label with the sequence number like records with ID

  def status_label_with_id( s, w )
    s < 0 ? '...' : ApplicationModel.some_text_and_id( status_label( s, w ), s )
  end

  # retrieve the label for the given task: use either with a single
  # parameter (which causes the object's wf_current_index to be used),
  # or with a specific wf_current_index

  def task_label( t = nil, w = nil )
    I18n.t( sprintf( '%s.workflows.w%02d.tasks.t%02d', @i18n_prefix, w || @wf_current_index, t || @wf_current_task )) 
  end

  # return the label with the sequence number like records with ID

  def task_label_with_id( t, w )
    ApplicationModel.some_text_and_id( task_label( t, w ), t )
  end

  # retrieve combined labels for status and task: use either with
  # two parameters for status and task or use an additional parameter
  # for the wf_current_index (otherwise, the object's wf_current_index
  # will be used)

  def status_task_label( s = nil, t = nil, w = nil )
    status_label( s , w ) + ' / ' + task_label( t, w )
  end

  # return the label with the sequence number like records with ID

  def status_task_label_with_id( s, t, w )
    status_label_with_id( s, w ) + ' / ' + task_label_with_id( t, w )
  end

  # for nested parameters where accepts_nested_parameters_for is set,
  # just return the given list

  def permitted_params
    @wf_permits[ @wf_current_index ][ @wf_current_task ]
  end

  # return true if given param is to be included (use this to determine in
  # a view whether an attribute is read-only); parameters can be one or
  # more symbols: if more than one, the first n-1 symbols refer to a hash
  # as required by permit, the last symbol to the array within that hash.

  def param_permitted?( *p )
    if p.length < 1 then
      raise ArgumentError.new( 'param_permitted? argument list must contain at least one item' )
    else
      p.each do |e|
        raise ArgumentError.new( 'param_permitted? argument must be a Symbol' ) unless e.kind_of? Symbol
      end
    end
    # check
    l = 0
    n = p.length
    a = @wf_permits[ @wf_current_index ][ @wf_current_task ]
    while n > 1
      # look for Hash with key p[ l ]
      found = false
      a.each do |e|
        if e.kind_of?( Hash )&& e.has_key?( p[ l ]) then
          a = e[ p[ l ]]
          l += 1
          n -= 1
          found = true
          break
        end
      end
      return false if not found
    end
    a.include?( p[ l ])
  end

end
