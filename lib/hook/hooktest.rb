#!/usr/bin/env ruby
url = 'hook://file/lnTV6JVH8?p=V29yay9MRVg=&n=site%20inspiration.pdf'

hooks = `osascript <<'APPLESCRIPT'
  tell application "Hook"
    set _mark to bookmark from URL "#{url}"
    set _hooks to bookmarks hooked to _mark
    return _hooks
  end tell
APPLESCRIPT`.strip

puts hooks
p hooks.inspect
