require 'test_helper'
class PcpSubjectsController0Test < ActionController::TestCase
  tests PcpSubjectsController

  setup do
    @pcp_subject = pcp_subjects( :one )
    session[ :current_user_id ] = accounts( :one ).id
  end

  test 'check class attributes' do
    validate_feature_class_attributes FEATURE_ID_MY_PCP_SUBJECTS, 
      ApplicationController::FEATURE_ACCESS_INDEX,
      ApplicationController::FEATURE_CONTROL_CUGRP
  end

  test 'should get index' do
    get :index
    assert_response :success
    refute_nil assigns( :pcp_subjects )
  end

  test 'should get new' do
    get :new
    assert_response :success
    refute_nil assigns( :pcp_subject )
    refute_nil assigns( :pcp_categories )
  end

  test 'should get release document' do
    get :show_release, id: @pcp_subject, step_no: 0
    refute_nil assigns( :pcp_curr_step )
    refute_nil assigns( :pcp_subject )
    assert_response :success
  end

  test 'cannot get release document for current step' do
    get :show_release, id: @pcp_subject, step_no: 1
    assert_response :not_found
  end

  test 'should release step' do
    assert_difference( 'PcpStep.count' ) do
      get :update_release, id: @pcp_subject
    end
    ps = assigns( :pcp_subject )
    cs = assigns( :pcp_curr_step )
    refute_nil ps
    refute_nil cs
    refute_nil assigns( :pcp_prev_step )
    refute_nil assigns( :pcp_viewing_group_map )
    assert_redirected_to pcp_release_doc_path( id: ps.id, step_no: cs.step_no )
  end

  test 'should get history' do
    get :show_history, id: @pcp_subject
    refute_nil assigns( :pcp_subject )
    refute_nil assigns( :pcp_curr_step )
    refute_nil assigns( :pcp_prev_step )
    refute_nil assigns( :pcp_viewing_group_map )
    assert_response :success
  end

  test 'should create pcp_subject' do
    assert_difference( 'PcpSubject.count', 1 ) do
      post :create, pcp_subject: {
        pcp_category_id: @pcp_subject.pcp_category_id,
        title: @pcp_subject.title, note: @pcp_subject.note,
        c_deputy_id: @pcp_subject.c_deputy_id, c_owner_id: @pcp_subject.c_owner_id,
        project_doc_id: @pcp_subject.project_doc_id,
        p_deputy_id: @pcp_subject.p_deputy_id, p_owner_id: @pcp_subject.p_owner_id,
        report_doc_id: @pcp_subject.report_doc_id }
      @pcp_subject = assigns( :pcp_subject )
      @pcp_step = assigns( :pcp_curr_step )
      refute_nil @pcp_subject
      refute_nil @pcp_step
    end
    assert_not_nil assigns( :pcp_curr_step )
    assert_redirected_to pcp_subject_path( assigns( :pcp_subject ))
  end

  test 'creation of pcp_subject fails' do
    assert_no_difference( 'PcpSubject.count' ) do
      post :create, pcp_subject: {
        pcp_category_id: @pcp_subject.pcp_category_id,
        note: 'X' * ( MAX_LENGTH_OF_NOTE + 1 )}
    end
    assert_template :new
    refute_nil assigns( :pcp_subject )
    refute_nil assigns( :pcp_categories )
  end

  test 'should show pcp_subject' do
    get :show, id: @pcp_subject
    refute_nil assigns( :pcp_subject )
    refute_nil assigns( :pcp_curr_step )
    refute_nil assigns( :pcp_prev_step )
    refute_nil assigns( :pcp_viewing_group_map )
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @pcp_subject
    refute_nil assigns( :pcp_curr_step )
    refute_nil assigns( :pcp_subject )
    refute_nil assigns( :pcp_prev_step )
    refute_nil assigns( :pcp_viewing_group_map )
    assert_response :success
  end

  test 'should update pcp_subject' do
    patch :update, id: @pcp_subject, pcp_subject: {
      title: @pcp_subject.title, note: @pcp_subject.note,
      c_deputy_id: @pcp_subject.c_deputy_id, c_owner_id: @pcp_subject.c_owner_id,
      project_doc_id: @pcp_subject.project_doc_id,
      p_deputy_id: @pcp_subject.p_deputy_id, p_owner_id: @pcp_subject.p_owner_id,
      report_doc_id: @pcp_subject.report_doc_id }
    refute_nil assigns( :pcp_curr_step )
    refute_nil assigns( :pcp_subject )
    refute_nil assigns( :pcp_prev_step )
    refute_nil assigns( :pcp_viewing_group_map )
    assert_redirected_to pcp_subject_path( assigns( :pcp_subject ))
  end

  test 'should update PCP Step' do
    patch :update, id: @pcp_subject, pcp_subject: {
      pcp_steps_attributes: { '0' => { id: pcp_steps( :one_two ), new_assmt: '1', note: '1' }}
    }
    @pcp_step = assigns( :pcp_curr_step )
    @pcp_subject = assigns( :pcp_subject )
    refute_nil @pcp_step
    refute_nil @pcp_subject
    @pcp_step.reload
    @pcp_subject.reload
    refute_nil assigns( :pcp_prev_step )
    refute_nil assigns( :pcp_viewing_group_map )
    assert_equal @pcp_step, pcp_steps( :one_two )
    assert_equal 1, @pcp_step.new_assmt
    assert_redirected_to pcp_subject_path( assigns( :pcp_subject ))
    assert_equal 0, @pcp_subject.valid_subject?
  end

  test 'should destroy pcp_subject' do
    assert_difference('PcpSubject.count', -1) do
      delete :destroy, id: @pcp_subject
    end
    assert_redirected_to pcp_subjects_path
  end
end
