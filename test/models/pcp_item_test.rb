require 'test_helper'
class PcpItemTest < ActiveSupport::TestCase

  test 'fixture 1' do
    pi = pcp_items( :one )
    assert pi.valid?
    assert pi.pcp_subject.id, pcp_subjects( :one ).id
    assert pi.pcp_step.id, pcp_steps( :one_two ).id
    assert_equal 1, pi.seqno
    assert_nil pi.pub_assmt
    assert_equal 0, pi.new_assmt
    assert_equal 1, pi.assessment
    assert_equal 0, pi.valid_item?
  end

  test 'fixture 2' do
    pi = pcp_items( :two )
    assert pi.valid?
    assert pi.pcp_subject.id, pcp_subjects( :one ).id
    assert pi.pcp_step.id, pcp_steps( :one_two ).id
    assert_equal 2, pi.seqno
    assert_nil pi.pub_assmt
    assert_equal 1, pi.new_assmt
    assert_equal 0, pi.assessment
    assert_equal 0, pi.valid_item?
  end

  test 'fixture 3' do
    pi = pcp_items( :three )
    assert pi.valid?
    assert pi.pcp_subject.id, pcp_subjects( :one ).id
    assert pi.pcp_step.id, pcp_steps( :one_two ).id
    assert_equal 3, pi.seqno
    assert_nil pi.pub_assmt
    assert_equal 0, pi.new_assmt
    assert_equal 0, pi.assessment
    assert_equal 0, pi.valid_item?
  end    

  test 'defaults' do
    pi = PcpItem.new
    refute pi.valid?
    assert_includes pi.errors, :pcp_subject_id
    assert_includes pi.errors, :pcp_step_id
    assert_includes pi.errors, :description
    assert_includes pi.errors, :author
    pi.pcp_subject = pcp_subjects( :one )
    pi.pcp_step = pcp_steps( :one_two )
    pi.seqno = 1
    pi.description = 'foobar'
    pi.author = 'I'
    assert pi.valid?, pi.errors.messages
  end

  test 'parent subject must exist' do
    pi = pcp_items( :one )
    pi.pcp_subject_id = nil
    refute pi.valid?
    assert_includes pi.errors, :pcp_subject_id
    pi.pcp_subject_id = 0
    refute pi.valid?
    assert_includes pi.errors, :pcp_subject_id
    pi.pcp_subject_id = pcp_subjects( :one ).id
    assert pi.valid?, pi.errors.messages
  end

  test 'parent step must exist' do
    pi = pcp_items( :one )
    pi.pcp_step_id = nil
    refute pi.valid?
    assert_includes pi.errors, :pcp_step_id
    pi.pcp_step_id = 0
    refute pi.valid?
    assert_includes pi.errors, :pcp_step_id
    pi.pcp_step_id = pcp_steps( :one_two ).id
    assert pi.valid?, pi.errors.messages
  end

  test 'parent subject and step must be related' do
    pi = pcp_items( :one )

    # create new subject

    ps = PcpSubject.new
    ps.pcp_category_id = pcp_subjects( :one ).pcp_category_id
    ps.title = 'foobar'
    ps.p_owner_id = accounts( :account_one ).id
    px = PcpStep.new
    assert_difference( [ 'PcpSubject.count', 'PcpStep.count' ], 1 )do
      assert ps.save, ps.errors.messages
      px.pcp_subject_id = ps.id
      assert px.save, px.errors.messages
    end
    assert_equal 0, ps.valid_subject?

    pi.pcp_subject_id = ps.id
    refute pi.valid?
    assert_includes pi.errors, :base
    refute_includes pi.errors, :pcp_subject_id

    pi.pcp_step_id = px.id
    assert_not pi.valid? # cannot assign to step_no 0

    px = PcpStep.new( pcp_subject: ps, step_no: 1 )
    assert_difference( 'PcpStep.count', 1 )do
      assert px.save, px.errors.messages
    end
    assert_equal 0, ps.valid_subject?
    pi.pcp_step_id = px.id
    assert pi.valid?, pi.errors.inspect

    pi.pcp_subject_id = pcp_subjects( :one ).id
    refute pi.valid?
    assert_includes pi.errors, :base
    refute_includes pi.errors, :pcp_step_id

    pi.pcp_step_id = pcp_steps( :one_two ).id
    assert pi.valid?
  end

  test 'next sequence number' do
    pi = PcpItem.new
    pi.pcp_subject_id = pcp_items( :two ).pcp_subject_id
    pi.set_next_seqno
    assert_equal 4, pi.seqno
    pi.description = 'foobar'
    pi.pcp_step_id = pcp_items( :two ).pcp_step_id
    pi.author = 'tester'
    assert pi.save
    pn = pi.dup
    pn.set_next_seqno
    assert_equal 5, pn.seqno
    assert_difference( 'PcpItem.count', -1 )do
      pcp_items( :one ).destroy
    end
    pn.set_next_seqno
    assert_equal 5, pn.seqno
    assert_difference( 'PcpItem.count', -1 )do
      pcp_items( :two ).destroy
    end
    pn.set_next_seqno
    assert_equal 5, pn.seqno
    assert_difference( 'PcpItem.count', -1 )do
      pcp_items( :three ).destroy
    end
    pn.set_next_seqno
    assert_equal 5, pn.seqno
    assert_difference( 'PcpItem.count', -1 )do
      pi.destroy
    end
    assert_equal 0, PcpItem.count
    pn.set_next_seqno
    assert_equal 1, pn.seqno
  end

  test 'get released items' do
    s = pcp_subjects( :one )
    pr = PcpItem.released( s )
    assert_equal 0, pr.count
    pr.each do |p|
      refute p.released?
    end
    # release items by adding new step
    pc = s.current_step
    pc.released_at = Time.now
    assert pc.save
    #
    px = PcpStep.new( pcp_subject: s, step_no: 2 )
    assert_difference( 'PcpStep.count' )do
      assert px.save, px.errors.inspect
    end
    s.reload
    assert_equal 0, s.valid_subject?
    pr = PcpItem.released( s )
    assert_equal 3, pr.count
    pr.each do |p|
      assert p.released?
    end
    # 
    pn = s.pcp_items.new
    pn.pcp_step = pc
    pn.set_next_seqno
    pn.author = 'me'
    pn.description = 'foobar'
    assert pn.save, pn.errors.inspect
    pr = PcpItem.released( s )
    assert_equal 4, pr.count
    pr.each do |p|
      assert p.released?
    end
  end

  test 'assessments' do
    cu = accounts( :account_one )
    # create new item, for second step
    ps = pcp_steps( :one_two )
    pi = nil
    assert_difference( 'PcpItem.count' )do
      pi = ps.pcp_items.create( pcp_subject: ps.pcp_subject, description: 'Item 4', seqno: 1, author: 'me' )
    end
    assert_equal 0, pi.valid_item?, pi.inspect
    assert_equal 0, pi.new_assmt
    assert_equal 0, pi.assessment
    assert_nil pi.pub_assmt
    # change of :assessment should also change :new_assmt here
    pi.assessment = 2
    assert_equal 2, pi.new_assmt
    # add internal comment to PCP Item w/o prior release
    pc0 = nil
    assert_difference( 'PcpComment.count' )do
      pc0 = pi.pcp_comments.create( description: 'Item 4, Comment 1', pcp_step: ps, author: 'me', assessment: 1 )
    end
    pi.reload

    assert_equal 0, pi.valid_item?, pi.inspect
    assert_nil pi.pub_assmt
    assert_equal 2, pi.new_assmt
    assert_equal 2, pi.assessment

    # make last comment public

    pc0.make_public
    pi.reload
    assert_equal 0, pi.valid_item?, pi.inspect
    assert_nil pi.pub_assmt
    assert_equal 1, pi.new_assmt
    assert_equal 2, pi.assessment

    # change assessment of last comment

    pc0.assessment = 2
    assert pc0.save, pc0.errors.inspect
    pi.reload
    assert_equal 0, pi.valid_item?, pi.inspect
    assert_nil pi.pub_assmt
    assert_equal 2, pi.new_assmt
    assert_equal 2, pi.assessment

    # release item with a new step

    ps_new = PcpStep.new( pcp_subject: ps.pcp_subject )
    ps_new.create_release_from( ps, cu )
    ps.set_release_data( cu )
    assert_difference( 'PcpStep.count' )do
      assert ps.save, ps.errors.inspect
      assert ps_new.save, ps_new.errors.inspect
    end
    ps = ps_new
    assert_no_difference( 'PcpItem.count' )do
      pi.release_item
      assert pi.save, pi.errors.inspect
    end
    assert_equal 0, pi.valid_item?, pi.inspect
    assert_equal 2, pi.pub_assmt
    assert_equal 2, pi.new_assmt
    assert_equal 2, pi.assessment

    assert_equal 1, pi.pcp_comments.count

    # change of :assessment (i.e. original assessment) has no effect on
    # PCP Item's integrity

    pi.assessment = 0
    assert_equal 2, pi.new_assmt
    assert_equal 0, pi.valid_item?, pi.inspect

    pi.assessment = 1
    assert_equal 2, pi.new_assmt
    assert_equal 0, pi.valid_item?, pi.inspect

    # therefore, we change it back

    pi.assessment = 2
    assert_equal 2, pi.new_assmt
    assert_equal 0, pi.valid_item?, pi.inspect

    # add internal comment #1 as first comment for new step

    pc1 = nil
    assert_difference( 'PcpComment.count' )do
      pc1 = pi.pcp_comments.create( description: 'Step 1, Comment 1', pcp_step: ps, author: 'me', assessment: 1 )
    end
    pi.reload
    assert_equal 0, pi.valid_item?, pi.inspect
    assert_equal 2, pi.pub_assmt
    assert_equal 1, pi.new_assmt
    assert_equal 2, pi.assessment

    # add internal comment #2

    pc2 = nil
    assert_difference( 'PcpComment.count' )do
      pc2 = pi.pcp_comments.create( description: 'Step 1, Comment 2', pcp_step: ps, author: 'me', assessment: 2 )
    end
    pi.reload
    assert_equal 0, pi.valid_item?, pi.inspect
    assert_equal 2, pi.pub_assmt
    assert_equal 2, pi.new_assmt
    assert_equal 2, pi.assessment

    # make comment #1 public - this is NOT the implemented process:
    # there only the last comment should be modified ...

    pc1.make_public
    pi.reload
    assert_equal 0, pi.valid_item?, pi.inspect
    assert_equal 2, pi.pub_assmt
    assert_equal 1, pi.new_assmt
    assert_equal 2, pi.assessment

    # now delete first comment

    assert_difference( 'PcpComment.count', -1 ){ pc1.delete }
    pi.update_new_assmt( nil )
    pi.reload
    assert_equal 0, pi.valid_item?, pi.inspect
    assert_equal 2, pi.pub_assmt
    assert_equal 2, pi.new_assmt
    assert_equal 2, pi.assessment

    # make one more comment and set it to public

    pc3 = nil
    assert_difference( 'PcpComment.count' )do
      pc3 = pi.pcp_comments.create( description: 'Step 1, Comment 3', pcp_step: ps, author: 'me', assessment: 1, is_public: true )
    end
    pi.reload
    assert_equal 0, pi.valid_item?, pi.inspect
    assert_equal 2, pi.pub_assmt
    assert_equal 1, pi.new_assmt
    assert_equal 2, pi.assessment

    # final comment, internal

    pc4 = nil
    assert_difference( 'PcpComment.count' )do
      pc4 = pi.pcp_comments.create( description: 'Step 1, Comment 4', pcp_step: ps, author: 'me', assessment: 2, is_public: false )
    end
    pi.reload
    assert_equal 0, pi.valid_item?, pi.inspect
    assert_equal 2, pi.pub_assmt
    assert_equal 1, pi.new_assmt
    assert_equal 2, pi.assessment

    # now, release this step and start a new one

    ps_new = PcpStep.new( pcp_subject: ps.pcp_subject )
    ps_new.create_release_from( ps, cu )
    ps.set_release_data( cu )
    assert_difference( 'PcpStep.count' )do
      assert ps.save, ps.errors.inspect
      assert ps_new.save, ps_new.errors.inspect
    end
    ps = ps_new
    assert_no_difference( 'PcpItem.count' )do
      pi.release_item
      assert pi.save, pi.errors.inspect
    end

    # we should have new_assmt from the previous step as new pub_assmt

    assert_equal 0, pi.valid_item?, pi.inspect
    assert_equal 1, pi.pub_assmt
    assert_equal 1, pi.new_assmt
    assert_equal 2, pi.assessment
  end

end
