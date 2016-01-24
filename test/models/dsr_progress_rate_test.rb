require 'test_helper'
class DsrProgressRateTest < ActiveSupport::TestCase

  test 'fixtures' do
    # there must be as many progress rates records as document states
    assert_equal DsrStatusRecord::DSR_STATUS_RECORD_STATUS_LABELS.size, DsrProgressRate.count
    for i in 0..DsrStatusRecord::DSR_STATUS_RECORD_STATUS_LABELS.size - 1
      p = DsrProgressRate.find( i )
      assert_equal i <= 10 ? i * 10 : 0, p.document_progress
    end
  end

  test 'defaults for new' do
    p = DsrProgressRate.new
    assert_equal 0, p.document_progress
    assert_equal 0, p.prepare_progress
    assert_equal 0, p.approve_progress
  end

  test 'document_progress range' do
    p = DsrProgressRate.new
    p.document_progress = -1
    refute p.valid?
    p.document_progress = 101
    refute p.valid?
  end

  test 'prepare_progress range' do
    p = DsrProgressRate.new
    p.prepare_progress = -1
    refute p.valid?
    p.prepare_progress = 101
    refute p.valid?
  end

  test 'approve_progress range' do
    p = DsrProgressRate.new
    p.approve_progress = -1
    refute p.valid?
    p.approve_progress = 101
    refute p.valid?
  end

end
