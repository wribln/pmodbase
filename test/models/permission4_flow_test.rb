require 'test_helper'

class Permission4FlowTest < ActiveSupport::TestCase

  setup do
    @p = Permission4Flow.new
  end

  test 'ensure workflow_id can be used' do
    p = permission4_flows( :dsr )
    
    p.workflow_id = nil
    refute p.valid?
    assert_includes p.errors, :workflow_id

    p.workflow_id = -1
    refute p.valid?
    assert_includes p.errors, :workflow_id

    p.workflow_id = p.feature.no_workflows
    refute p.valid?
    assert_includes p.errors, :workflow_id
  end

  test 'verify default settings' do
    assert_nil @p.account_id
    assert_nil @p.feature_id
    assert_nil @p.workflow_id
    assert_nil @p.label
    assert_nil @p.tasklist
    assert_not @p.valid?
  end

  test 'ensure valid fixture' do
    p = permission4_flows( :rsr )
    assert p.valid?

    p = permission4_flows( :dsr )
    assert p.valid?
  end

  test 'given feature must exist' do
    p = permission4_flows( :rsr )
    p.feature_id = nil
    assert_not p.valid?
    assert_includes p.errors, :feature_id

    p.feature_id = FEATURE_ID_MAX_PLUS_ONE
    assert_not p.valid?
    assert_includes p.errors, :feature_id
  end

  test 'given account must exist' do
    p = permission4_flows( :rsr )
    p.account_id = nil
    assert_not p.valid?
    assert_includes p.errors, :account_id

    p.account_id = 0
    assert_not p.valid?
    assert_includes p.errors, :account_id
  end

  test 'task list contents' do
    p = permission4_flows( :rsr )

    p.tasklist = '1'
    assert p.valid?

    p.tasklist = '1,1'
    assert p.valid?
    assert_equal '1',p.tasklist

    p.tasklist = '  1 , 2, 3 '
    assert p.valid?
    assert_equal '1,2,3', p.tasklist
  end

  test 'permission for task method' do
    p = permission4_flows( :rsr )
    p.tasklist = nil
    assert_not p.permission_for_creation?
    assert_not p.permission_for_task?( 1 )
    assert_not p.permission_for_task?( 2 )
    assert_not p.permission_for_task?( 3 )
    p.tasklist = '0'
    assert     p.permission_for_creation?
    assert_not p.permission_for_task?( 1 )
    assert_not p.permission_for_task?( 2 )
    assert_not p.permission_for_task?( 3 )
    p.tasklist = '1'
    assert_not p.permission_for_creation?
    assert     p.permission_for_task?( 1 )
    assert_not p.permission_for_task?( 2 )
    assert_not p.permission_for_task?( 3 )
    p.tasklist = '2'
    assert_not p.permission_for_creation?
    assert_not p.permission_for_task?( 1 )
    assert     p.permission_for_task?( 2 )
    assert_not p.permission_for_task?( 3 )
    p.tasklist = '3'
    assert_not p.permission_for_creation?
    assert_not p.permission_for_task?( 1 )
    assert_not p.permission_for_task?( 2 )
    assert     p.permission_for_task?( 3 )
    p.tasklist = '0,1'
    assert     p.permission_for_creation?
    assert     p.permission_for_task?( 1 )
    assert_not p.permission_for_task?( 2 )
    assert_not p.permission_for_task?( 3 )
    p.tasklist = '1,2'
    assert_not p.permission_for_creation?
    assert     p.permission_for_task?( 1 )
    assert     p.permission_for_task?( 2 )
    assert_not p.permission_for_task?( 3 )
    p.tasklist = '2,3'
    assert_not p.permission_for_creation?
    assert_not p.permission_for_task?( 1 )
    assert     p.permission_for_task?( 2 )
    assert     p.permission_for_task?( 3 )        
    p.tasklist = '0,2'
    assert     p.permission_for_creation?
    assert_not p.permission_for_task?( 1 )
    assert     p.permission_for_task?( 2 )
    assert_not p.permission_for_task?( 3 )        
    p.tasklist = '0,1,2,3'
    assert     p.permission_for_creation?
    assert     p.permission_for_task?( 1 )
    assert     p.permission_for_task?( 2 )
    assert     p.permission_for_task?( 3 )        
   end

end
