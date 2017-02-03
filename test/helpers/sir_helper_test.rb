class SirHelperTest < ActionView::TestCase
  include ApplicationHelper

  test 'entry actions' do
    si = sir_items( :one )
  	refute_nil entry_action( :forward, si )
    refute_nil entry_action( :respond, si )
    refute_nil entry_action( :comment, si )
    se = sir_entries( :one )
    refute_nil entry_action( :edit, se )
    refute_nil entry_action( :show, se )
    refute_nil entry_action( :delete, se )
  end

end
