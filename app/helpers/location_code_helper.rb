module LocationCodeHelper

  # format a float as mileage xxx+xxx.xxx (long)
  #                           xxx+xxx     (short)

  def db_formatted_km( f, long = true )
    return if f.nil?
    if f < 0 then
      sgn = '-'
      val = -f 
    else
      sgn = '+'
      val = f 
    end
    aval = val.divmod( 1000 )
    sprintf( long ? '%d%s%07.3f' : '%d%s%03d', aval.first, sgn, aval.last )
  end

  # format a float as decimal with same precision as mileage

  def db_formatted_km_len( f, long = true )
    return if f.nil?
    if long
      number_with_precision( f, precision: 3, separator: '.', delimiter: ' ' )
    else
      f.to_i
    end
  end

end
