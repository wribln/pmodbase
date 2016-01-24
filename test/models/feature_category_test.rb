require 'test_helper'

class FeatureCategoryTest < ActiveSupport::TestCase

  test "default settings" do
    fc = FeatureCategory.new
    assert_empty fc.label
    assert_equal 0, fc.seqno
  end

  test "required attributes" do
    fc = FeatureCategory.new
    assert_not fc.valid?
    assert_includes fc.errors, :label
  end

end
