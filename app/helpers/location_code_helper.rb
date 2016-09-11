module LocationCodeHelper

  # format a float as mileage xxx+xxx

  def db_formatted_km( f )
    return if f.nil?
    if f < 0 then
      sgn = '-'
      val = -f 
    else
      sgn = '+'
      val = f 
    end
    aval = val.divmod( 1000 )
    sprintf( '%d%s%07.3f', aval.first, sgn, aval.last )
  end

  # format a float as decimal with same precision as mileage

  def db_formatted_km_len( f )
    return if f.nil?
    number_with_precision( f, precision: 3, separator: '.', delimiter: ' ' )
  end

end
