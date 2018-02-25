require 'test_helper'
class IsrAgreementsControllerTest < ActionDispatch::IntegrationTest

  setup do
    signon_by_user accounts( :one )
  end

  test 'check class attributes' do
    get isr_agreements_path
    validate_feature_class_attributes FEATURE_ID_ISR_AGREEMENTS, 
      ApplicationController::FEATURE_ACCESS_SOME,
      ApplicationController::FEATURE_CONTROL_NONE, 0
  end

  test 'should get index' do
    get isr_agreements_path
    assert_response :success
    assert_not_nil assigns( :isr_agreements )
  end

  test 'should get stats' do
    get isr_statistics_path
    assert_response :success
    ifs = assigns( :if_stats )
    ias = assigns( :ia_stats )
    assert_equal 1, ifs[ 0 ]
    assert_equal 1, ias[ 0 ]
  end

  test 'CSV download 2' do
    get isr_statistics_path( format: :xls )
    p = Regexp.new <<'END_OF_CSV'
table_id;line_id;label;count;as at: \d{4}-\d{2}-\d{2} \d{2}:\d{2} UTC
1;1;identified;1
1;2;defined-open;0
1;3;defined-frozen;0
1;4;not applicable;0
1;5;withdrawn;0
3;1;open;1
3;2;agreed;0
3;3;resolved;0
3;4;closed;0
3;5;in revision;0
3;6;status change;0
3;7;superseded;0
3;8;terminated;0
3;9;cancelled;0
3;10;rejected;0
3;11;withdrawn;0
END_OF_CSV
  assert_match p, response.body
  end      

end
