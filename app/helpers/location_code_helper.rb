module LocationCodeHelper

  # format an integer as mileage xxx+xxx

  def db_formatted_km( i )
    return if i.nil?
    if i < 0 then
      sgn = '-'
      val = -i 
    else
      sgn = '+'
      val = i 
    end
    hi_val = ( val / 1000 ).to_i
    lo_val = val - ( hi_val * 1000 )
    sprintf( '%d%s%3.3d', hi_val, sgn, lo_val )
  end

end
