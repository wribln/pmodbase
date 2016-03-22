module HashtagsHelper

  # this helps to format grouped hashtags:
  # split hashtag into two parts (array of two):
  # if hashtag has no suffix (is group header), return hashtag
  # if hashtag has suffix, return '&nbsp;&nbsp;&nbsp;_' + suffix

  def split_hash( code )
    r = code.split( '_', 2 )
    r.count == 1 ? code : "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_#{ r.last }".html_safe
  end

end
