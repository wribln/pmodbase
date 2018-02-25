require 'test_helper'
class FilterControllerTest < ActionDispatch::IntegrationTest

  def check_clean_up( hash_before, hash_after )
    params = ActionController::Parameters.new( hash_before )
    params.clean_up
    assert_equal hash_after, params
  end

  test 'empty hash' do
    check_clean_up({ },{ })
  end

  test 'one parameter w/ empty string' do
    check_clean_up({ :p => '' },{ })
  end

  test 'one parameter w/ empty array' do
    check_clean_up({ :p => [] },{ }) 
  end

  test 'one parameter w/ array, one element with empty string' do
    check_clean_up({ :p => [ '' ] },{ })
  end

  test 'one parameter w/ array, one element with nil' do
    check_clean_up({ :p => [ nil ] },{ })
  end

  test 'one parameter w/ array, one element with 0' do
    check_clean_up({ :p => [ 0 ] },{ 'p' => [ 0 ] })
  end

  test 'one parameter w/ array, one element with "0"' do
    check_clean_up({ :p => [ '0' ] },{ 'p' => [ '0' ]})
  end

  test 'one parameter w/ array, one element with two values' do
    check_clean_up({ :p => [ nil, 0 ]},{ 'p' => [ nil, 0 ]})
  end

  # two parameters

  test 'two parameters w/ empty string' do
    check_clean_up({ :p1 => 'p1', :p2 => '' },{ 'p1' => 'p1' })
  end

  test 'two parameters w/ empty array' do
    check_clean_up({ :p1 => 'p1', :p2 => [] },{ 'p1' => 'p1' }) 
  end

  test 'two parameters w/ array, one element with empty string' do
    check_clean_up({ :p1 => 'p1', :p2 => [ '' ] },{ 'p1' => 'p1' })
  end

  test 'two parameters w/ array, one element with nil' do
    check_clean_up({ :p1 => 'p1', :p2 => [ nil ] },{ 'p1' => 'p1' })
  end

  test 'two parameters w/ array, one element with 0' do
    check_clean_up({ :p1 => 'p1', :p2 => [ 0 ] },{ 'p1' => 'p1', 'p2' => [ 0 ] })
  end

  test 'two parameters w/ array, one element with "0"' do
    check_clean_up({ :p1 => 'p1', :p2 => [ '0' ] },{ 'p1' => 'p1', 'p2' => [ '0' ] })
  end

end
