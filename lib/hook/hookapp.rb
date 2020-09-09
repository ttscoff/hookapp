# frozen_string_literal: true

# Hook.app functions
module HookApp
  # Create a single regex for validation of an
  # array by first char or full match
  def format_regex(options)
    fmt_rx_array = []
    options.map {|fmt| fmt_rx_array.push(fmt.sub(/^(.)(.*?)$/, '\1(\2)?')) }
    Regexp.new("^(#{fmt_rx_array.join('|')})$",'i')
  end

  # Check if fmt fully matches or matches the first
  # character of available options
  # return full valid format or nil
  def validate_format(fmt, options)
    valid_format_rx = options.map { |format| format.sub(/^(.)(.*)$/, '^\1(\2)?$') }
    valid_format = nil
    valid_format_rx.each_with_index do |rx, i|
      cmp = Regexp.new(rx, 'i')
      next unless fmt =~ cmp

      valid_format = options[i]
      break
    end
    valid_format
  end

  def bookmark_for(url)
    url.valid_hook!
    raise "Invalid target: #{url}" unless url

    mark = `osascript <<'APPLESCRIPT'
      tell application "Hook"
        set _hook to make bookmark with data "#{url}"
        return name of _hook & "||" & address of _hook & "||" & path of _hook
      end tell
    APPLESCRIPT`.strip
    mark.split_hook
  end

  def get_hooks(url)
    url.valid_hook!
    raise "Invalid target: #{url}" unless url

    hooks = `osascript <<'APPLESCRIPT'
      tell application "Hook"
        set _mark to make bookmark with data "#{url}"
        set _hooks to hooked bookmarks of _mark
        set _out to {}
        repeat with _hook in _hooks
          set _out to _out & (name of _hook & "||" & address of _hook & "||" & path of _hook)
        end repeat
        set {astid, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "^^"}
        set _output to _out as string
        set AppleScript's text item delimiters to astid
        return _output
      end tell
    APPLESCRIPT`.strip
    hooks.split_hooks
  end

  def bookmark_from_app(app, opts)
    mark = `osascript <<'APPLESCRIPT'
      tell application "System Events" to set front_app to name of first application process whose frontmost is true
      tell application "#{app}" to activate
      delay 2
      tell application "Hook"
        set _hook to (bookmark from active window)
        set _output to (name of _hook & "||" & address of _hook & "||" & path of _hook)
      end tell
      tell application front_app to activate
      return _output
    APPLESCRIPT`.strip.split_hook
    title = mark[:name].empty? ? "#{app.cap} link" : mark[:name]
    output = opts[:markdown] ? "[#{title}](#{mark[:url]})" : mark[:url]

    if opts[:copy]
      "Copied Markdown link for '#{title}' to clipboard" if output.clip
    else
      output
    end
  end

  def search_name(search)
    `osascript <<'APPLESCRIPT'
      set searchString to "#{search.strip}"
      tell application "Hook"
        set _marks to every bookmark whose name contains searchString
        set _out to {}
        repeat with _hook in _marks
          set _out to _out & (name of _hook & "||" & address of _hook & "||" & path of _hook)
        end repeat
        set {astid, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "^^"}
        set _output to _out as string
        set AppleScript's text item delimiters to astid
        return _output
      end tell
    APPLESCRIPT`.strip.split_hooks
  end

  def search_path_or_address(search)
    `osascript <<'APPLESCRIPT'
      set searchString to "#{search.strip}"
      tell application "Hook"
        set _marks to every bookmark whose path contains searchString or address contains searchString
        set _out to {}
        repeat with _hook in _marks
          set _out to _out & (name of _hook & "||" & address of _hook & "||" & path of _hook)
        end repeat
        set {astid, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "^^"}
        set _output to _out as string
        set AppleScript's text item delimiters to astid
        return _output
      end tell
    APPLESCRIPT`.strip.split_hooks
  end

  def all_bookmarks
    `osascript <<'APPLESCRIPT'
      tell application "Hook"
        set _marks to every bookmark
        set _out to {}
        repeat with _hook in _marks
          set _out to _out & (name of _hook & "||" & address of _hook & "||" & path of _hook)
        end repeat
        set {astid, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "^^"}
        set _output to _out as string
        set AppleScript's text item delimiters to astid
        return _output
      end tell
    APPLESCRIPT`.strip.split_hooks
  end

  def search_bookmarks(search, opts)
    unless search.nil? || search.empty?
      result = search_name(search)
      unless opts[:names_only]
        more_results = search_path_or_address(search)
        result = result.concat(more_results).uniq
      end
    else
      result = all_bookmarks
    end

    separator = opts[:format] == 'paths' && opts[:null_separator] ? "\0" : "\n"

    output = output_array(result, opts)

    if opts[:format] =~ /^v/
      "Search results for: #{search}\n---------\n" + output.join("\n")
    else
      output.join(separator)
    end
  end

  def clip_bookmark(url, opts)
    mark = bookmark_for(url)
    copy_bookmark(mark[:name], mark[:url], opts)
  end

  def copy_bookmark(title, url, opts)
    raise "No URL found" if url.empty?
    title = title.empty? ? 'No title' : title
    output = opts[:markdown] ? "[#{title}](#{url})" : url
    output.clip
    %(Copied #{opts[:markdown] ? 'Markdown link' : 'Hook URL'} for '#{title}' to clipboard)
  end

  def select_hook(marks)
    intpad = marks.length.to_s.length + 1
    marks.each_with_index do |mark, i|
      STDERR.printf "%#{intpad}d) %s\n", i + 1, mark[:name]
    end
    STDERR.print 'Open which bookmark: '
    sel = STDIN.gets.strip.to_i
    raise 'Invalid selection' unless sel.positive? && sel <= marks.length

    marks[sel - 1]
  end

  def open_gui(url)
    `osascript <<'APPLESCRIPT'
    tell application "Hook"
      set _mark to make bookmark with data "#{url.valid_hook}"
      invoke on _mark
    end tell
    APPLESCRIPT`
  end

  def open_linked(url)
    marks = get_hooks(url)
    if marks.empty?
      warn "No hooks found for #{url}"
    else
      res = select_hook(marks)
      `open '#{res[:url]}'`
    end
  end

  def link_files(args)
    target = args.pop
    target.valid_hook!
    raise "Invalid target: #{target}" unless target

    args.each do |file|
      file.valid_hook!
      raise "Invalid target: #{file}" unless file

      puts "Linking #{file} and #{target}..."
      `osascript <<'APPLESCRIPT'
        tell application "Hook"
          set _mark1 to make bookmark with data "#{file}"
          set _mark2 to make bookmark with data "#{target}"
          hook _mark1 and _mark2
          return true
        end tell
      APPLESCRIPT`
    end
    "Linked #{args.length} files to #{target}"
  end

  def clone_hooks(args)
    target = args.pop.valid_hook
    source = args[0].valid_hook

    if target && source
      hooks = get_hooks(source)
      hooks.each do |hook|
        `osascript <<'APPLESCRIPT'
          tell application "Hook"
            set _mark1 to make bookmark with data "#{hook[:url]}"
            set _mark2 to make bookmark with data "#{target}"
            hook _mark1 and _mark2
            return true
          end tell
        APPLESCRIPT`
      end
      "Hooks from #{source} cloned to #{target}"
    else
      raise 'Invalid file specified'
    end
  end

  def delete_all_hooks(url)
    STDERR.print "Are you sure you want to delete ALL hooks from #{url} (y/N)? "
    res = STDIN.gets.strip
    if res =~ /^y/i
      get_hooks(url).each do |hook|
        `osascript <<'APPLESCRIPT'
          tell application "Hook"
            set _mark1 to make bookmark with data "#{hook[:url]}"
            set _mark2 to make bookmark with data "#{url}"
            unhook _mark1 and _mark2
            return true
          end tell
        APPLESCRIPT`
      end
      "Removed all hooks from #{url}"
    end
  end

  def delete_hooks(args, opts)
    urls = args.map(&:valid_hook).delete_if { |url| !url }
    output = []
    if opts[:all]
      urls.each_with_index do |url, i|
        raise "Invalid target: #{args[i]}" unless url

        output.push(delete_all_hooks(url))
      end
      return output.join("\n")
    end

    if urls.length == 2
      source = urls[0]
      target = urls[1]
      `osascript <<'APPLESCRIPT'
        tell application "Hook"
          set _mark1 to make bookmark with data "#{source}"
          set _mark2 to make bookmark with data "#{target}"
          unhook _mark1 and _mark2
          return true
        end tell
      APPLESCRIPT`
      "Hook removed between #{source} and #{target}"
    else
      raise 'Invalid number of URLs or files specified'

    end
  end

  def link_all(args)
    args.each do |file|
      source = file.valid_hook
      link_to = args.dup.map(&:valid_hook).reject { |url| url == source }
      link_to.each do |url|
        `osascript <<'APPLESCRIPT'
          tell application "Hook"
            set _mark1 to make bookmark with data "#{source}"
            set _mark2 to make bookmark with data "#{url}"
            hook _mark1 and _mark2
            return true
          end tell
        APPLESCRIPT`
      end
    end
    "Linked #{args.length} files to each other"
  end

  def linked_bookmarks(args, opts)
    result = []

    separator = args.length == 1 && opts[:format] == 'paths' && opts[:null_separator] ? "\0" : "\n"

    if args.nil? || args.empty?
      result = output_array(all_bookmarks, opts)
    else
      args.each do |url|
        source_mark = bookmark_for(url)
        filename = source_mark[:name]

        case opts[:format]
        when /^m/
          filename = "[#{source_mark[:name]}](#{source_mark[:url]})"
          filename += " <file://#{CGI.escape(source_mark[:path])}>" if source_mark[:path]
        when /^p/
          filename = "File: #{source_mark[:name]}"
          filename += " (#{source_mark[:path]})" if source_mark[:path]
        when /^h/
          filename = "File: #{source_mark[:name]}"
          filename += " (#{source_mark[:url]})" if source_mark[:url]
        else
          filename = "Bookmarks attached to #{source_mark[:path] || source_mark[:url]}"
        end

        hooks_arr = get_hooks(url)

        output = output_array(hooks_arr, opts)
        result.push({ file: filename, links: output.join(separator) })
      end


      if result.length > 1 || opts[:format] == 'verbose'
        result.map! do |res|
          "#{res[:file]}\n\n#{res[:links]}\n"
        end
      else
        result.map! do |res|
          res[:links]
        end
      end
    end
    result.join(separator)
  end

  def output_array(hooks_arr, opts)
    if !hooks_arr.empty?
      hooks_arr.reject! { |h| h[:path].nil? || h[:path] == '' } if opts[:files_only]

      output = []

      case opts[:format]
      when /^m/
        hooks_arr.each do |h|
          if h[:name].empty?
            title = h[:url]
          else
            title = h[:name]
          end
          output.push("- [#{title}](#{h[:url]})")
        end
      when /^p/
        hooks_arr.each do |h|
          output.push(h[:path].nil? ? h[:url] : h[:path])
        end
      when /^h/
        hooks_arr.each do |h|
          output.push(h[:url])
        end
      else
        hooks_arr.each do |h|
          output.push("Title: #{h[:name]}\nPath: #{h[:path]}\nAddress: #{h[:url]}\n---------------------")
        end
      end
    else
      output = ['No bookmarks']
    end

    output
  end
end


