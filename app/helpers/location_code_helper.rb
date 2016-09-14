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
    if long 
      fmt = '%d%s%07.3f'
      prc = 3
    else
      fmt = '%d%s%03d'
      prc = 0
    end
    aval[ 1 ] = aval[ 1 ].round( prc )
    sprintf( fmt, aval[ 0 ], sgn, aval[ 1 ] )
  end

  # format a float as decimal with same precision as mileage

  def db_formatted_km_len( f, long = true )
    return if f.nil?
    if long
      number_with_precision( f, precision: 3, separator: '.', delimiter: ' ' )
    else
      number_with_precision( f, precision: 0, delimiter: ' ')
    end
  end

end
