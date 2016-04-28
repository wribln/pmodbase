# helper to determine if the string is a positive integer

# this function returns true if the string contains only digits;
# 0 and leading zeros are allowed but no (+) sign

class String
  def is_n?
    /\A\d+\z/ === self
  end
end
