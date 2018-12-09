module StatsHelper

  # compute percents (avoid division by 0)

  def percent_rel( percent, count )
    percent * count == 0 ? 0 : percent / count
  end

  def percent_abs( part, whole )
    part * whole == 0 ? 0 : part * 100 / whole
  end

  # format absolute numbers

  def db_formatted_abs( i )
    sprintf( '%.0f', i ) unless i.nil?
  end    

  # format percents (based on integer values, blank for 0)

  def db_formatted_pct( i )
    sprintf( '%.0f%%', i ) unless i.nil?
  end

  # given two values, compute and output the variance in percent

  def variance_pct( curr_val, base_val )
    if base_val == 0 then
      curr_val == 0 ? 0 : 100
    else
      ( curr_val - base_val ) * 100 / base_val
    end
  end

  # when should a weight be treated as 0? When it is printed as 0?

  def weight_zero?( d )
    d.abs < 0.05
  end

  # format weights, show two decimals

  def db_formatted_weight( d )
    sprintf( '%.2f', d) unless d.nil?
  end

end