require 'test_helper'

class WebLinkTest < ActiveSupport::TestCase

  test "fixture usefulness" do
    wl = web_links( :one )
    assert wl.label.length <= MAX_LENGTH_OF_LABEL
    refute wl.hyperlink.blank?
    refute_nil wl.seqno
    assert wl.seqno.kind_of? Integer
  end

  test "label must not be blank" do
    wl = WebLink.new
    assert_not wl.valid?
    assert_includes wl.errors, :label
    wl.label = "Something"
    assert wl.valid?
  end

  test "hyperlinks" do
    wl = WebLink.new
    wl.label = "Hyperlinktest"
    wl.hyperlink = ""
    assert wl.valid? # empty hyperlink is ok

    wl.hyperlink = nil 
    assert wl.valid? # nil hyperlink is ok

    wl.hyperlink = "test" # this should fail - no valid url
    refute wl.valid?
    assert_includes wl.errors, :hyperlink
  end

end
