require 'test_helper'
require './lib/assets/work_flow_helper.rb'
class WorkFlowHelperTest < ActionView::TestCase

  setup do
    @wfh = WorkFlowHelper.new( [[[[1,1]],
                                 [[2,2],[3,2]],
                                 [[-1,2]]],
                                [[[0,1]],
                                 [[-1,1]]]
                               ], [[[:id1, id1_set: [:id1a, :id1b]],[:id2],[:id3]],[[:id4],[:id5]]], 'rfc_status_records' )
  end

  test "setup" do
    assert_not_nil @wfh.i18n_prefix
    assert_not_nil @wfh.wf_transitions
    assert_nil @wfh.wf_current_index
    assert_nil @wfh.wf_current_task
    assert_nil @wfh.wf_current_status
    assert @wfh.validate_instance
  end

  test "counts" do
    assert_equal 2,@wfh.no_of_workflows
    assert_equal 3,@wfh.no_of_tasks(0)
    assert_equal 2,@wfh.no_of_tasks(1)
    assert_equal 4,@wfh.no_of_states(0)
    assert_equal 1,@wfh.no_of_states(1)
  end

  test "validate_instance - standard case" do
    assert_equal 2, @wfh.wf_transitions.length
    assert_equal 3, @wfh.wf_transitions[0].length
    assert_equal 1, @wfh.wf_transitions[0][0].length
    assert_equal 2, @wfh.wf_transitions[0][1].length
    assert_equal 1, @wfh.wf_transitions[0][2].length
    assert_equal 2, @wfh.wf_transitions[1].length
    assert_equal 1, @wfh.wf_transitions[1][0].length
    assert_equal 1, @wfh.wf_transitions[1][1].length
    assert_equal 2, @wfh.wf_transitions[0][0][0].length
    assert_equal 1, @wfh.wf_transitions[0][0][0][0]
    assert_equal 1, @wfh.wf_transitions[0][0][0][1]
    assert_equal 2, @wfh.wf_transitions[0][1][0].length
    assert_equal 2, @wfh.wf_transitions[0][1][0][0]
    assert_equal 2, @wfh.wf_transitions[0][1][0][1]
    assert_equal 3, @wfh.wf_transitions[0][1][1][0]
    assert_equal 2, @wfh.wf_transitions[0][1][1][1]
    assert_equal 2, @wfh.wf_transitions[0][2][0].length
    assert_equal -1, @wfh.wf_transitions[0][2][0][0]
    assert_equal 2, @wfh.wf_transitions[0][2][0][1]
    assert_equal 2, @wfh.wf_transitions[1][0][0].length
    assert_equal 0, @wfh.wf_transitions[1][0][0][0]
    assert_equal 1, @wfh.wf_transitions[1][0][0][1]
    assert_equal 2, @wfh.wf_transitions[1][1][0].length
    assert_equal -1, @wfh.wf_transitions[1][1][0][0]
    assert_equal 1, @wfh.wf_transitions[1][1][0][1]
  end

  # tests for wf_permits

  test "wf_permits 0" do
    assert @wfh.validate_instance
    assert_equal 2, @wfh.wf_permits.length
    assert_equal 3, @wfh.wf_permits[ 0 ].length
    assert_equal 2, @wfh.wf_permits[ 1 ].length
    assert_equal :id1, @wfh.wf_permits[ 0 ][ 0 ][ 0 ]
    assert_equal :id2, @wfh.wf_permits[ 0 ][ 1 ][ 0 ]
    assert_equal :id3, @wfh.wf_permits[ 0 ][ 2 ][ 0 ]
    assert_equal :id4, @wfh.wf_permits[ 1 ][ 0 ][ 0 ]
    assert_equal :id5, @wfh.wf_permits[ 1 ][ 1 ][ 0 ]
  end

  test "initialize current" do
    @wfh.initialize_current( 0 )
    assert_equal 0, @wfh.wf_current_index
    assert_equal 0, @wfh.wf_current_status
    assert_equal 0, @wfh.wf_current_task
    assert @wfh.validate_instance

    @wfh.initialize_current( 1, 1 )
    assert_equal 1, @wfh.wf_current_index
    assert_equal 1, @wfh.wf_current_status
    assert_equal 0, @wfh.wf_current_task
    assert @wfh.validate_instance

    @wfh.initialize_current( 0, 2, 1 )
    assert_equal 0, @wfh.wf_current_index
    assert_equal 2, @wfh.wf_current_status
    assert_equal 1, @wfh.wf_current_task
    assert @wfh.validate_instance
  end

  test "step through tasks - workflow 0" do

    @wfh.initialize_current 0, 0, 0
    assert @wfh.status_change_possible?
    @wfh.update_status_task 1
    assert_equal 0, @wfh.wf_current_index
    assert_equal 1, @wfh.wf_updated_status
    assert_equal 1, @wfh.wf_updated_task

    @wfh.initialize_current 0, 1, 1
    assert @wfh.status_change_possible?
    @wfh.update_status_task 1
    assert_equal 2, @wfh.wf_updated_status
    assert_equal 2, @wfh.wf_updated_task

    @wfh.initialize_current 0, 2, 2
    assert_not @wfh.status_change_possible?
    @wfh.update_status_task 1
    assert_equal 2, @wfh.wf_updated_status
    assert_equal 2, @wfh.wf_updated_task
  end

  test "step through tasks - workflow 1" do

    @wfh.initialize_current 1, 0, 0
    assert @wfh.status_change_possible?
    @wfh.update_status_task 1
    assert_equal 1, @wfh.wf_current_index
    assert_equal 0, @wfh.wf_updated_status
    assert_equal 1, @wfh.wf_updated_task
    @wfh.initialize_current 1, 0, 1
    assert_not @wfh.status_change_possible?
    @wfh.update_status_task 1
    assert_equal 0, @wfh.wf_updated_status
    assert_equal 1, @wfh.wf_updated_task
  end

  test "validate negative 1" do
    wfh_bad = WorkFlowHelper.new( '', nil, '' )
    x = assert_raises( ArgumentError ){ wfh_bad.validate_instance }
    assert_equal( 'wf_transitions must be an Array', x.message )
  end

  test "validate negative 2" do
    wfh_bad = WorkFlowHelper.new( [], nil, '' )
    x = assert_raises( ArgumentError ){ wfh_bad.validate_instance }
    assert_equal( 'wf_transitions must not be empty', x.message )
  end

  test "validate negative 3a" do
    wfh_bad = WorkFlowHelper.new( [ 0 ], nil, '' )
    x = assert_raises( ArgumentError ){ wfh_bad.validate_instance }
    assert_equal( 'wf_transitions[ 0 ] must be an Array', x.message )
  end

  test "validate negative 3b" do
    wfh_bad = WorkFlowHelper.new( [[]], nil, '' )
    x = assert_raises( ArgumentError ){ wfh_bad.validate_instance }
    assert_equal( 'wf_transitions[ 0 ] must not be empty', x.message )
  end

  test "validate negative 4a" do
    wfh_bad = WorkFlowHelper.new( [[ 0 ]], nil, '' )
    x = assert_raises( ArgumentError ){ wfh_bad.validate_instance }
    assert_equal( 'wf_transitions[ 0 ][ 0 ] must be an Array', x.message )
  end

  test "validate negative 4b" do
    wfh_bad = WorkFlowHelper.new( [[[]]], nil, '' )
    x = assert_raises( ArgumentError ){ wfh_bad.validate_instance }
    assert_equal( 'wf_transitions[ 0 ][ 0 ] must not be empty', x.message )
  end

  test "validate negative 4c" do
    wfh_bad = WorkFlowHelper.new( [[[ 0 ]]], nil, '' )
    x = assert_raises( ArgumentError ){ wfh_bad.validate_instance }
    assert_equal( 'wf_transitions[ 0 ][ 0 ][ 0 ] must be an Array', x.message )
  end

  test "validate negative 5" do
    wfh_bad = WorkFlowHelper.new( [[[[ 0, 'nil' ]]]], nil, '' )
    x = assert_raises( ArgumentError ){ wfh_bad.validate_instance }
    assert_equal( 'wf_transitions[ 0 ][ 0 ][ 0 ][ 1 ] must be an Integer', x.message )
  end

  test "validate i18n_prefix" do
    wfh_bad = WorkFlowHelper.new( [[[[ -1, 0 ]]]], nil, nil )
    x = assert_raises( ArgumentError ){ wfh_bad.validate_instance }
    assert_equal( 'i18n_prefix must be a String', x.message )
  end

  test "validate wf_current_index" do
    @wfh.initialize_current ''
    x = assert_raises( ArgumentError ){ @wfh.validate_instance }
    assert_equal( 'wf_current_index must be an Integer', x.message )
    @wfh.initialize_current -1
    x = assert_raises( ArgumentError ){ @wfh.validate_instance }
    assert_equal( 'wf_current_index outside of range ( 0...1 )', x.message )
    @wfh.initialize_current 2
    x = assert_raises( ArgumentError ){ @wfh.validate_instance }
    assert_equal( 'wf_current_index outside of range ( 0...1 )', x.message )
    @wfh.initialize_current 1
    assert true, @wfh.validate_instance
  end

  test "workflow label 1" do
    assert_equal( 'incoming', @wfh.workflow_label( 0 ))
    assert_equal( 'outgoing', @wfh.workflow_label( 1 ))
  end

  test "workflow label 2" do
    @wfh.initialize_current 0
    assert_equal( 'incoming', @wfh.workflow_label )
    @wfh.initialize_current 1
    assert_equal( 'outgoing', @wfh.workflow_label )
  end

  test "workflow labels" do
    assert_equal( [[ 'incoming', 0 ],[ 'outgoing', 1 ]], @wfh.workflow_labels_for_select )
  end

  test "status and task labels for select 1" do
    assert_equal( '<initial>',    @wfh.status_label( 0, 0 ))
    assert_equal( '<start new workflow>',   @wfh.task_label(   0, 0 ))
    assert_equal( '<initial> / <start new workflow>', @wfh.status_task_label( 0, 0, 0 ))
    assert_equal( 'new',              @wfh.status_label( 1, 0 ))
    assert_equal( 'Receive Question', @wfh.task_label(   1, 0 ))
    assert_equal( 'new / Receive Question', @wfh.status_task_label( 1, 1, 0 ))
  end

  test "status and task labels for select 2" do
    @wfh.initialize_current 0
    assert_equal( '<initial>',        @wfh.status_label( 0 ))
    assert_equal( '<start new workflow>',   @wfh.task_label(   0 ))
    assert_equal( '<initial> / <start new workflow>', @wfh.status_task_label( 0, 0 ))
    assert_equal( 'new',              @wfh.status_label( 1 ))
    assert_equal( 'Receive Question', @wfh.task_label(   1 ))
    assert_equal( 'new / Receive Question', @wfh.status_task_label( 1, 1 ))
  end

  test "next_status_task_labels for select" do
    @wfh.initialize_current 0, 0, 0
    assert @wfh.validate_instance
    assert_equal([[ '<initial> / <start new workflow>', 0 ],[ 'new / Receive Question', 1 ]], @wfh.next_status_task_labels_for_select )
  end

  # tests for wf_permits

  test "wf_permits 1" do
    wfh_bad = WorkFlowHelper.new( @wfh.wf_transitions, '', 'rfc_status_records' )
    x = assert_raises( ArgumentError ){ wfh_bad.validate_instance }
    assert_equal( 'wf_permits must be an Array', x.message )
  end    

  test "wf_permits 2a" do
    wfh_bad = WorkFlowHelper.new( @wfh.wf_transitions, [], 'rfc_status_records' )
    x = assert_raises( ArgumentError ){ wfh_bad.validate_instance }
    assert_equal( 'wf_permits, level 1 must have same length (0) as wf_transitions (2)', x.message )
  end    

  test "wf_permits 2b" do
    wfh_bad = WorkFlowHelper.new( @wfh.wf_transitions, [1], 'rfc_status_records' )
    x = assert_raises( ArgumentError ){ wfh_bad.validate_instance }
    assert_equal( 'wf_permits, level 1 must have same length (1) as wf_transitions (2)', x.message )
  end    

  test "wf_permits 3a" do
    wfh_bad = WorkFlowHelper.new( @wfh.wf_transitions, [1,2], 'rfc_status_records' )
    x = assert_raises( ArgumentError ){ wfh_bad.validate_instance }
    assert_equal( 'wf_permits[ 0 ] must be an Array', x.message )
  end    

  test "wf_permits 3b" do
    wfh_bad = WorkFlowHelper.new( @wfh.wf_transitions, [[1],2], 'rfc_status_records' )
    x = assert_raises( ArgumentError ){ wfh_bad.validate_instance }
    assert_equal( 'wf_permits[ 0 ] must be same length (1) as corresponding @wf_transitions (3)', x.message )
  end   

  test "wf_permits 3c" do
    wfh_bad = WorkFlowHelper.new( @wfh.wf_transitions, [[1,2,3],2], 'rfc_status_records' )
    x = assert_raises( ArgumentError ){ wfh_bad.validate_instance }
    assert_equal( 'wf_permits[ 0 ][ 0 ] must be an Array', x.message )
  end

  test "wf_permits 3d" do
    wfh_bad = WorkFlowHelper.new( @wfh.wf_transitions, [[[1],2,3],2], 'rfc_status_records' )
    x = assert_raises( ArgumentError ){ wfh_bad.validate_instance }
    assert_equal( 'wf_permits[ 0 ][ 0 ][ 0 ] must be a Symbol or a Hash', x.message )
  end

  test "wf_permits 3e" do
    wfh_bad = WorkFlowHelper.new( @wfh.wf_transitions, [[[:id],2,3],2], 'rfc_status_records' )
    x = assert_raises( ArgumentError ){ wfh_bad.validate_instance }
    assert_equal( 'wf_permits[ 0 ][ 1 ] must be an Array', x.message )
  end

  test "wf_permits 3f" do
    wfh_bad = WorkFlowHelper.new( @wfh.wf_transitions, [[[:id],[:id],[:id]],2], 'rfc_status_records' )
    x = assert_raises( ArgumentError ){ wfh_bad.validate_instance }
    assert_equal( 'wf_permits[ 1 ] must be an Array', x.message )
  end

  test "wf_permits 3g" do
    wfh_bad = WorkFlowHelper.new( @wfh.wf_transitions, [[[:id],[:id],[:id]],[2]], 'rfc_status_records' )
    x = assert_raises( ArgumentError ){ wfh_bad.validate_instance }
    assert_equal( 'wf_permits[ 1 ] must be same length (1) as corresponding @wf_transitions (2)', x.message )
  end   

  test "wf_permits 3h" do
    wfh_bad = WorkFlowHelper.new( @wfh.wf_transitions, [[[:id],[:id],[:id]],[2,2]], 'rfc_status_records' )
    x = assert_raises( ArgumentError ){ wfh_bad.validate_instance }
    assert_equal( 'wf_permits[ 1 ][ 0 ] must be an Array', x.message )
  end

  test "wf_permits 3i" do
    wfh_bad = WorkFlowHelper.new( @wfh.wf_transitions, [[[:id],[:id],[:id]],[[2],2]], 'rfc_status_records' )
    x = assert_raises( ArgumentError ){ wfh_bad.validate_instance }
    assert_equal( 'wf_permits[ 1 ][ 0 ][ 0 ] must be a Symbol or a Hash', x.message )
  end

  test "wf_permits 3j" do
    wfh_bad = WorkFlowHelper.new( @wfh.wf_transitions, [[[:id],[:id],[:id]],[[:id],2]], 'rfc_status_records' )
    x = assert_raises( ArgumentError ){ wfh_bad.validate_instance }
    assert_equal( 'wf_permits[ 1 ][ 1 ] must be an Array', x.message )
  end

  test "wf_permits 3k" do
    wfh_bad = WorkFlowHelper.new( @wfh.wf_transitions, [[[:id],[:id],[:id]],[[:id],[2]]], 'rfc_status_records' )
    x = assert_raises( ArgumentError ){ wfh_bad.validate_instance }
    assert_equal( 'wf_permits[ 1 ][ 1 ][ 0 ] must be a Symbol or a Hash', x.message )
  end

  test "permitted_params exceptions" do
    @wfh.initialize_current( 0, 0, 0 )
    x = assert_raises( ArgumentError ){ @wfh.param_permitted? }
    assert_equal( 'param_permitted? argument list must contain at least one item', x.message )
    x = assert_raises( ArgumentError ){ @wfh.param_permitted?( 1 )}
    assert_equal( 'param_permitted? argument must be a Symbol', x.message )
  end

  test "permitted_params 0 0 0" do
    @wfh.initialize_current( 0, 0, 0 )
    assert_equal [:id1, id1_set: [:id1a, :id1b]], @wfh.permitted_params
    assert @wfh.param_permitted?( :id1 )
    assert_not @wfh.param_permitted?( :id1_set )
    assert @wfh.param_permitted?( :id1_set, :id1a )
    assert @wfh.param_permitted?( :id1_set, :id1b )
    assert_not @wfh.param_permitted?( :id1_set, :id1c )
    assert_not @wfh.param_permitted?( :id2 )
    assert_not @wfh.param_permitted?( :id3 )
    assert_not @wfh.param_permitted?( :id4 )
    assert_not @wfh.param_permitted?( :id5 )
  end

  test "permitted_params 0 0 1" do
    @wfh.initialize_current( 0, 0, 1 )
    assert_equal [ :id2 ], @wfh.permitted_params
    assert_not @wfh.param_permitted?( :id1 )
    assert_not @wfh.param_permitted?( :id1_set )
    assert_not @wfh.param_permitted?( :id1_set, :id1a )
    assert_not @wfh.param_permitted?( :id1_set, :id1b )
    assert_not @wfh.param_permitted?( :id1_set, :id1c )
    assert @wfh.param_permitted?( :id2 )
    assert_not @wfh.param_permitted?( :id3 )
    assert_not @wfh.param_permitted?( :id4 )
    assert_not @wfh.param_permitted?( :id5 )
  end

  test "permitted_params 0 0 2" do
    @wfh.initialize_current( 0, 0, 2 )
    assert_equal [ :id3 ], @wfh.permitted_params
    assert @wfh.param_permitted?( :id3 )
    assert_not @wfh.param_permitted?( :id1 )
    assert_not @wfh.param_permitted?( :id1_set )
    assert_not @wfh.param_permitted?( :id1_set, :id1a )
    assert_not @wfh.param_permitted?( :id1_set, :id1b )
    assert_not @wfh.param_permitted?( :id2 )
    assert_not @wfh.param_permitted?( :id4 )
    assert_not @wfh.param_permitted?( :id5 )
  end

  test "permitted_params 1 0 0" do
    @wfh.initialize_current( 1, 0, 0 )
    assert_equal [ :id4 ], @wfh.permitted_params
    assert @wfh.param_permitted?( :id4 )
    assert_not @wfh.param_permitted?( :id1 )
    assert_not @wfh.param_permitted?( :id1_set )
    assert_not @wfh.param_permitted?( :id1_set, :id1a )
    assert_not @wfh.param_permitted?( :id1_set, :id1b )
    assert_not @wfh.param_permitted?( :id2 )
    assert_not @wfh.param_permitted?( :id3 )
    assert_not @wfh.param_permitted?( :id5 )
  end

  test "permitted_params 1 0 1" do
    @wfh.initialize_current( 1, 0, 1 )
    assert_equal [ :id5 ], @wfh.permitted_params
    assert @wfh.param_permitted?( :id5 )
    assert_not @wfh.param_permitted?( :id1 )
    assert_not @wfh.param_permitted?( :id1_set )
    assert_not @wfh.param_permitted?( :id1_set, :id1a )
    assert_not @wfh.param_permitted?( :id1_set, :id1b )
    assert_not @wfh.param_permitted?( :id2 )
    assert_not @wfh.param_permitted?( :id3 )
    assert_not @wfh.param_permitted?( :id4 )
  end

  test "all_states_for_select" do
    assert_equal ([
      ["incoming...","0"],
      ["...<initial>","0,0"],
      ["...new","0,1"],
      ["...assigned","0,2"],
      ["...re-evaluate","0,3"],
      ["outgoing...","1"],
      ["...<initial>","1,0"]]),
      @wfh.all_states_for_select
  end

end
