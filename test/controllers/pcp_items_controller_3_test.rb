require 'test_helper'
class PcpItemsController3Test < ActionController::TestCase
  tests PcpItemsController

  # test various scenarios for PCP Items and Comments

  setup do
    @pcp_subject = pcp_subjects( :two )
    @account_p = accounts( :one )
    @account_c = accounts( :two )
    session[ :current_user_id ] = @account_p.id
    assert @pcp_subject.pcp_members.destroy_all
  end

  # use PCP Subject prior to release to commenting party

  test 'conditions' do
    assert_equal 0, @pcp_subject.current_step.step_no
  end

  # make sure assessment changes can only be done by commenting party

  test 'assessment changes' do

    



  end

end