require './lib/assets/work_flow_helper.rb'

# extends the work_flow_helper class by replacing the parameter permission
# handling with a different scheme: Here, the creation of the permitted
# parameter set is done dynamically by processing all respective calls to
# permit_params.
#
# permit_params defines for a set of parameters whether this set is permitted
# to be shown or even to be edited for any of the given Feature Access Levels
# and current workflow tasks.
#
# Author: Wilfried Roemer

class WorkFlowHelperDyn < WorkFlowHelper

  # list of parameters which can be shown / edited

  attr_reader :wfd_show_parameters
  attr_reader :wfd_edit_parameters

  # we also need to know the current feature access level

  attr_reader :wfd_current_fal

  # initialize internal objects before initializing parent's objects

  def initialize( wf_transitions, i18n_prefix )
    @wfd_show_parameters = []
    @wfd_edit_parameters = []
    @wfd_current_fal = -1
    super( wf_transitions, nil, i18n_prefix )
  end

  def initialize_current( index, status = 0, task = 0, fal = false )
    @wfd_current_fal = ( fal - 1 ) if fal
    super( index, status, task )
  end

  # permitted parameters are in wfh_edit_parameters

  def permitted_params
    @wfd_edit_parameters
  end

  # param_permitted? must be used differently, hence disable the
  # parent's version

  undef_method :param_permitted?

  # permitted_to_show/edit?( :xyz ) returns true if :xyz is in the list
  # of currently permitted parameters enabled for showing/editing

  def permitted_to_show?( parameter )
    @wfd_show_parameters.include?( parameter )
  end

  def permitted_to_edit?( parameter )
    @wfd_edit_parameters.include?( parameter )
  end

  def permitted_to_display?( parameter )
    @wfd_show_parameters.include?( parameter ) or @wfd_edit_parameters.include?( parameter )
  end

  # returns the current access level

  def current_access_level
    @wfd_current_fal + 1
  end

  # repeatedly calling add_parameters sets up the information structure
  # containing the parameters to be shown or to be edited: 
  # [ parameters       ] an array of parameter names (as symbols)
  # [ access_levels    ] an array with access level indicators
  #                      (0) no (1) show (2) edit
  #                      index 0 corresponds to access level 1
  # [ workflow_tasks   ] an array of applicable workflow tasks
  # [ workflow_indeces ] an array of applicable workflow indeces/types
  # 
  # depending on the current setting of the workflow state

  def add_parameters( parameters, access_levels, workflow_tasks, workflow_indeces = [ 0 ])
    return unless @wfd_current_fal >= 0 && @wfd_current_fal < access_levels.length 
    return unless workflow_indeces.include? @wf_current_index
    return unless workflow_tasks.include? @wf_current_task
    case access_levels[ @wfd_current_fal ]
    when :show
      @wfd_show_parameters.push( *parameters )
    when :edit
      @wfd_edit_parameters.push( *parameters )
    else
      return
    end
  end

  # validate the internal data structures

  def validate_instance
    super
    # @wfd_show/edit_paramaeters must be arrays of symbols
    @wfd_show_parameters.each_with_index do |sp,i|
      unless sp.kind_of? Symbol then
        raise ArgumentError.new( "permitted show parameter at [ #{ i } ] = #{ sp.to_s } is not a Symbol" )
      end
    end
    @wfd_edit_parameters.each_with_index do |ep,i|
      unless ep.kind_of? Symbol then
        raise ArgumentError.new( "permitted edit parameter at [ #{ i } ] = #{ ep.to_s } is not a Symbol" )
      end
    end
    # @wfd_show/edit_parameters must not have duplicates
    dup_param1 = @wfd_show_parameters.detect {|e| @wfd_show_parameters.rindex(e) != @wfd_show_parameters.index(e) }
    unless dup_param1.nil? then
      raise ArgumentError.new( "permitted show parameter #{ dup_param1 } occurs more than once.")
    end
    dup_param1 = @wfd_edit_parameters.detect {|e| @wfd_edit_parameters.rindex(e) != @wfd_edit_parameters.index(e) }
    unless dup_param1.nil? then
      raise ArgumentError.new( "permitted edit parameter #{ dup_param1 } occurs more than once.")
    end
    # intersection of both arrays should be empty because at any time
    # a parameter can only be shown or editable...
    dup_params = @wfd_show_parameters & @wfd_edit_parameters
    unless dup_params.length == 0
      raise ArgumentError.new( "parameters #{ dup_params.to_s } are defined to both show and edit" )
    end
  end

end 