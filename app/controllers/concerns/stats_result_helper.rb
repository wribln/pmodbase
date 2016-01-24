# supports handling of statistical data collections

module StatsResultHelper
  extend ActiveSupport::Concern 

  # having two result sets - one with current, one with baseline data,
  # merge those two sets such that they become a single result set
  # with the group variables and the combined current and baseline
  # data
  #
  # curr_set and base_set have the same number of columns, the first
  # <key_cols> columns are the grouping (key) variables, the last
  # <val_cols> columns are the columns with values to be copied.

  def merge_stats( curr_set, base_set, key_cols, val_cols )
    result_set = []
    zeros_set = Array.new( val_cols, 0 ).freeze
    curr_ptr = 0
    base_ptr = 0
    done = ( curr_set.blank? || curr_ptr > curr_set.size || base_ptr.blank? || base_ptr > base_set.size )
    # loop and return result
    until done
      case curr_set[ curr_ptr ][ 0, key_cols ] <=> base_set[ base_ptr ][ 0, key_cols ]
      when -1 # curr before base
        result_set << ( curr_set[ curr_ptr ][  0, key_cols ] + curr_set[ curr_ptr ][ -val_cols, val_cols ] + zeros_set )
        curr_ptr += 1
        done = ( curr_ptr >= curr_set.size )
      when 0 # curr same as base
        result_set << ( curr_set[ curr_ptr ][  0, key_cols ] + curr_set[ curr_ptr ][ -val_cols, val_cols ] + base_set[ base_ptr ][ -val_cols, val_cols ])
        curr_ptr += 1
        base_ptr += 1
        done = ( curr_ptr >= curr_set.size || base_ptr >= base_set.size )
      when +1 # base before curr
        result_set << ( base_set[ base_ptr ][ 0, key_cols ] + zeros_set + base_set[ base_ptr ][ -val_cols, val_cols ])
        base_ptr += 1
        done = ( base_ptr >= base_set.size )
      else
        raise 'curr_set <=> base_set result is nil'
      end
    end
    # now add rest from curr_set - if any
    while curr_set && curr_ptr < curr_set.size
      result_set << ( curr_set[ curr_ptr ][  0, key_cols ] + curr_set[ curr_ptr ][ -val_cols, val_cols ] + zeros_set )
      curr_ptr += 1
    end
    # now add rest from base_set - if any
    while base_set && base_ptr < base_set.size
      result_set << ( base_set[ base_ptr ][ 0, key_cols ] + zeros_set + base_set[ base_ptr ][ -val_cols, val_cols ])
      base_ptr += 1
    end
    return result_set
  end

  # sum_stats create a result set with the sums of the each group defined
  # by the keys in the first key_cols entries.

  def sub_totals( source_set, key_cols, val_cols )
    if source_set.empty? then
      []
    else
      result_set = [ source_set[ 0 ][ 0, key_cols ] + Array.new( val_cols, 0 )]
      last_ptr = 0
      source_set.each do |src|
        if src[ 0, key_cols ] == result_set[ last_ptr ][ 0, key_cols ]
          (-val_cols..-1).each{ |i| result_set[ last_ptr ][ i ] += src[ i ] }
        else
          result_set << src[ 0, key_cols ] + src[ -val_cols, val_cols ]
          last_ptr += 1
        end
      end
      result_set
    end
  end

  # almost the same as above but for the simpler calulcation of the grand total

  def grand_total( source_set, val_cols )
    result_set = Array.new( val_cols, 0 )
    unless source_set.nil? then
      source_set.each do |src|
        (-val_cols..-1).each{ |i| result_set[ i ] += src[ i ] }
      end
    end
    result_set
  end


  # I need one more: the overall statistics which uses only a single key column
  # and returns a hash with the key being the contents of the key_col, and the
  # value of the hash entry being the sum of value columns as array.
  #
  # IMPORTANT: key_col is the INDEX of the source_set row holding the key (0...n)

  def over_alls( source_set, key_col, val_cols )
    result_set = Hash.new{ Array.new( val_cols, 0 )}
    source_set.each do |src|
      r = result_set[ src[ key_col ]]
      (-val_cols..-1).each do |i|
        r[ i ] += src[ i ]
      end
      result_set[ src[ key_col ]] = r
    end
    result_set
  end

end