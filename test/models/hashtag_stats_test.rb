require 'test_helper'
class HashtagStatsTest < ActiveSupport::TestCase

  def validate_hashtags_stats
    refute_nil @hashstats, 'assume a non-empty hash for this test'
    # each value must be a hashtag - integer pair
    @hashstats.each_pair do |hsk,hsv|
      assert_match /#[A-Za-z][A-Za-z0-9\_]*=?\d*/,hsk
      assert hsv.is_a?( Integer )
    end
  end

  test 'various hash keys' do
    @hashstats = Hashtag.new_stats
    validate_hashtags_stats
    @hashstats[ '#NYC_HIC'] = 9
    @hashstats[ '#ABC' ] = 0
    @hashstats[ '#NYC'] = 0
    validate_hashtags_stats

    hashstats_ary = Hashtag.to_sorted_a( @hashstats )

    assert_equal 0, Hashtag.take_count!( '#XZY', @hashstats )
    validate_hashtags_stats
    Hashtag.take_count!( '#NYC_HIC', @hashstats )
    validate_hashtags_stats
    Hashtag.take_count!( '#ABC', @hashstats )
    validate_hashtags_stats
  end

  test 'collect hashtags information' do
    @hashstats = Hashtag.new_stats
    Hashtag.collect_hashstats( '#ABC #ABC=5 #ABC_XYZ #ABC_XYZ=9 just another #HASH', @hashstats )
    validate_hashtags_stats
    assert_equal 16, @hashstats[ '#ABC' ]
    assert_equal 10, @hashstats[ '#ABC_XYZ' ]
    assert_equal 1, @hashstats[ '#HASH' ]
    assert_equal 3, @hashstats.size
  end

  test 'collect on the fly 0' do
    hashtag_line = '#ABC #ABC=5 #ABC_XYZ #ABC_XYZ=9 just another #HASH'
    hashtags = []
    hashcount = Hashtag.collect_hashcounts( hashtag_line, hashtags )
    assert_equal hashtags.size, hashcount.size
    assert_equal 0, hashcount.size
  end

  test 'collect on the fly 1' do
    hashtag_line = '#ABC #ABC=5 #ABC_XYZ #ABC_XYZ=9 just another #HASH'
    hashtags = %w( #ABC #ABC_XYZ )
    hashcount = Hashtag.collect_hashcounts( hashtag_line, hashtags )
    assert_equal hashtags.size, hashcount.size
    assert_equal 16, hashcount[ 0 ]
    assert_equal 10, hashcount[ 1 ]
  end

  test 'collect on the fly 2' do
    hashtag_line = '#ABC #ABC=5 #ABC_XYZ #ABC_XYZ=9 just another #HASH'
    hashtags = %w( #XYZ #XYZ_ABC )
    hashcount = Hashtag.collect_hashcounts( hashtag_line, hashtags )
    assert_equal hashtags.size, hashcount.size
    assert_equal 0, hashcount[ 0 ]
    assert_equal 0, hashcount[ 1 ]
  end

  test 'collect on the fly 3' do
    hashtag_line = 'a long string without any real hashtags ... #'
    hashtags = %w( #XYZ #XYZ_ABC )
    hashcount = Hashtag.collect_hashcounts( hashtag_line, hashtags )
    assert_equal hashtags.size, hashcount.size
    assert_equal 0, hashcount[ 0 ]
    assert_equal 0, hashcount[ 1 ]
  end

end
