# Provides methods to create the wf_permits data structure used by
# the WorkFlowHelper class
#
# Author: Wilfried Roemer

class WorkFlowParams

  # this array contains the number of tasks for each workflow type;
  # this attribute allows some consistency checks

  attr_reader :wfp_count_of_tasks

  # provides the complete list of all possibly permitted record variables
  # as an array of symbols

  attr_reader :wfp_param_set

  # this will finally be the result of this excercise: the list of permitted
  # attributes per workflow and task

  attr_reader :wfp_permitted_params

  # initialize: for each workflow within a record structure provide the
  # number of tasks for @wfp_tasks

  def initialize( count_of_tasks )
    unless count_of_tasks.kind_of? Array then
      raise ArgumentError.new( 'count_of_tasks must be an Array' )
    end
    count_of_tasks.each_with_index do | tc, i |
      unless tc.kind_of? Integer then
        raise ArgumentError.new( "count_of_tasks[ #{ i } ] = #{ tc } must be an Integer" )
      end
      unless tc >= 0 then
        raise ArgumentError.new( "count_of_tasks[ #{ i } ] = #{ tc } must be >= 0" )
      end
    end
    @wfp_count_of_tasks = count_of_tasks
    @wfp_param_set = nil
    @wfp_permitted_params = Array.new( @wfp_count_of_tasks.length ){ |i| Array.new( @wfp_count_of_tasks[ i ])}
  end

  # add all possible parameters to the instance: this must be an array of
  # Symbols

  def all_params( *param_set )
    unless param_set.kind_of? Array then
      raise ArgumentError.new( 'param_set must be an Array' )
    end
    param_set.each_with_index do | ps, i |
      unless ps.kind_of? Symbol then
        raise ArgumentError.new ("param_set[ #{ i } ] = #{ ps } must be a Symbol" )
      end
    end
    @wfp_param_set = param_set
  end

  # allow parameters per workflow and task

  def check_preconditions( wf = nil, t = nil )
    if @wfp_param_set.nil? then
      raise ArgumentError.new ('@wfp_param_set not yet defined (nil)')
    end
    unless wf.nil? then
      unless wf >= 0 and wf < @wfp_permitted_params.length
        raise ArgumentError.new( "wf out of range (0..#{ @wfp_permitted_params.length})" )
      end
    end
    unless t.nil? then
      unless t >= 0 && t < @wfp_permitted_params[ wf ].length
        raise ArgumentError.new( "t out of range (0..#{ @wfp_permitted_params.length})" )
      end
    end
  end
  private :check_preconditions    

  def permit_all( wf, t )
    check_preconditions( wf, t )
    @wfp_permitted_params[ wf ][ t ] = @wfp_param_set
  end

  def permit_none( wf, t )
    check_preconditions( wf, t )
    @wfp_permitted_params[ wf ][ t ] = []
  end

  def permit_all_but( wf, t, *params )
    check_preconditions( wf, t )
    @wfp_permitted_params[ wf ][ t ] = @wfp_param_set - params
  end

  def permit_none_but( wf, t, *params )
    check_preconditions( wf, t )
    @wfp_permitted_params[ wf ][ t ] = @wfp_param_set & params
  end

  # show which params are permitted

  def permitted_params( wf, t )
    check_preconditions( wf, t )
    @wfp_permitted_params[ wf ][ t ]
  end

  # validate resulting data structure

  def validate
    n_bad = 0
    check_preconditions
    # no entry must be nil
    @wfp_permitted_params.each_with_index do | p, i |
      if p.nil? then
        raise ArgumentError.new( "@wfp_permitted_params[ #{ i } ] not set (nil)" )
      end
      p.each_with_index do | pp, j |
        if pp.nil? then
          n_bad = n_bad + 1
          puts "@wfp_permitted_params for workflow #{ i }, task #{ j } not defined"
        end
      end      
    end
    if n_bad > 0 then
      raise ArgumentError.new( "#{ n_bad } @wfp_permitted_params not defined" )
    end
  end

  # output the resulting data structure - ready for use

  def dump_params
    puts
    puts "Permitted Parameters:"
    puts
    puts "\t["
    @wfp_permitted_params.each_with_index do | p, i |
      puts "\t ["
      p.each_with_index do | pp, j |
        sep = ( j + 1 < p.length ) ? ',' : ''
        puts "\t  #{ pp.to_s }#{ sep }"
      end
      sep = ( i + 1 < @wfp_permitted_params.length ) ? ',' : ''
      puts "\t ]#{ sep }"
    end
    puts "\t]"
    puts
  end

end