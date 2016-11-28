# recursively collect descendants of hash b at index i and return in c at i

def collect_descendants( b, c, r, i )
  if c[ i ].nil?
    c[ i ] = [ i ]
    b[ i ].each do | j |
      collect_descendants( b, c, i, j )
    end
  end
  return if r == i
  if( c[ r ] & c[ i ]).empty?
    c[ r ].concat( c[ i ])
  else
    raise ArgumentError, "cycle detected while adding #{ i }"
  end
end


# Step 0: Start with array of key / parent relationships as pairs
#         parent is nil if no parent exists

a = [[ 1, 6 ], [ 2, 2 ],
     [ 3, 1 ], [ 4, 1 ],
     [ 5, 3 ], [ 6, 3 ],
     [ 7, 6 ], [ 8, 6 ]]

puts a.inspect

# Step 1: Create hash b where b contains direct descendants, nil if none

b = Hash.new
a.each do | x |
  b[ x.first ] = Array.new unless x.first.nil?
end

a.each do | x |
  next if x.last.nil? # nothing to do if x has no parent
  begin
    if b[ x.last ].nil?
      raise ArgumentError, "#{ x.inspect } references non-existing node #{ x.last }"
    elsif x.first == x.last
      raise ArgumentError, "#{ x.inspect } references itself"
    else
      b[ x.last ].push( x.first )
    end
  rescue ArgumentError
  end
end

puts b.inspect
    
# Step 2 - create hash c where c contains key and keys of all descendants

begin

c = Hash.new
b.each_key do | k |
  collect_descendants( b, c, k, k )
end

  rescue ArgumentError => e
    puts e.message
end
puts c.inspect

