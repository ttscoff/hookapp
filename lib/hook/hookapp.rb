# frozen_string_literal: true

require 'shellwords'
require 'uri'
# Hook.app functions
class HookApp
  # Create a single regex for validation of an
  # array by first char or full match.
  def format_regex(options)
    fmt_rx_array = []
    options.map {|fmt| fmt_rx_array.push(fmt.sub(/^(.)(.*?)$/, '\1(\2)?')) }
    Regexp.new("^(#{fmt_rx_array.join('|')})$",'i')
  end

  # Check if format fully matches or matches the first
  # character of available options.
  # Return full valid format or nil
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

  # Get a Hook bookmark for file or URL. Return bookmark hash.
  def bookmark_for(url)
    url.valid_hook!
    raise "Invalid target: #{url}" unless url

    begin
      mark = `osascript <<'APPLESCRIPT'
        tell application "Hook"
          set _hook to make bookmark with data "#{url}"
          if _hook is missing value
            return ""
          else
            return name of _hook & "||" & address of _hook & "||" & path of _hook
          end if
        end tell
      APPLESCRIPT`.strip
    rescue p => e
      raise e
    end

    raise "Error getting bookmark for #{url}" if mark.empty?
    mark.split_hook
  end

  # Get bookmarks hooked to file or URL. Return array of bookmark hashes.
  def get_hooks(url)
    url.valid_hook!
    raise "Invalid target: #{url}" unless url

    hooks = `osascript <<'APPLESCRIPT'
      tell application "Hook"
        set _mark to make bookmark with data "#{url}"
        if _mark is missing value
          return ""
        end if
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

  # Get a bookmark from the foreground document of specified app.
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

  # Search boomark names/titles. Return array of bookmark hashes.
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

  # Search bookmark paths and addresses. Return array of bookmark hashes.
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

  # Get all known bookmarks. Return array of bookmark hashes.
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

  # Search bookmarks, using both names and addresses unless options contain ":names_only".
  # Return results as formatted list.
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
      "Search results for: #{search}\n---------\n" + output.join("\n") if output
    else
      output.join(separator) if output
    end
  end

  # Create a bookmark for specified file/url and copy to the clipboard.
  def clip_bookmark(url, opts)
    mark = bookmark_for(url)
    copy_bookmark(mark[:name], mark[:url], opts)
  end

  # Create a bookmark from specified title and url and copy to the clipboard.
  def copy_bookmark(title, url, opts)
    raise "No URL found" if url.empty?
    title = title.empty? ? 'No title' : title
    output = opts[:markdown] ? "[#{title}](#{url})" : url
    output.clip
    %(Copied #{opts[:markdown] ? 'Markdown link' : 'Hook URL'} for '#{title}' to clipboard)
  end

  # Generate a menu of available hooks for selecting one or more hooks to operate on.
  # Revamped to use `fzf`, which is embedded as `lib/helpers/fuzzyfilefinder` to avoid any conflicts.
  # Allows multiple selections with tab key, and type-ahead fuzzy filtering of results.
  def select_hook(marks)
    # intpad = marks.length.to_s.length + 1
    # marks.each_with_index do |mark, i|
    #   STDERR.printf "%#{intpad}d) %s\n", i + 1, mark[:name]
    # end
    # STDERR.print 'Open which bookmark: '
    # sel = STDIN.gets.strip.to_i
    # raise 'Invalid selection' unless sel.positive? && sel <= marks.length

    # marks[sel - 1]

    options = marks.map {|mark|
      if mark[:name]
        id = mark[:name]
      elsif mark[:path]
        id = mark[:path]
      elsif mark[:url]
        id = mark[:url]
      else
        return false
      end

      if mark[:path]
        loc = File.dirname(mark[:path])
      elsif mark[:url]
        url = URI.parse(mark[:url])
        id = mark[:url]
        loc = url.scheme + " - " + url.hostname
      else
        loc = ""
      end

      "#{id}\t#{mark[:path]}\t#{mark[:url]}\t#{loc}"
    }.delete_if { |mark| !mark }

    raise "Error processing available hooks" if options.empty?

    args = ['--layout=reverse-list',
            '--header="esc: cancel, tab: multi-select, return: open > "',
            '--prompt="  Select hooks > "',
            '--multi',
            '--tabstop=4',
            '--delimiter="\t"',
            '--with-nth=1,4',
            '--height=60%',
            '--min-height=10'
          ]

    fzf = File.join(File.dirname(__FILE__), '../helpers/fuzzyfilefinder')

    sel = `echo #{Shellwords.escape(options.join("\n"))} | '#{fzf}' #{args.join(' ')}`.chomp
    res = sel.split(/\n/).map { |s|
      ps = s.split(/\t/)
      { name: ps[0], path: ps[1], url: ps[2] }
    }

    if res.size == 0
      raise 'Cancelled (empty response)'
    end

    res
  end

  # Open the Hook GUI for browsing/performing actions on a file or url
  def open_gui(url)
    result = `osascript <<'APPLESCRIPT'
    tell application "Hook"
      set _mark to make bookmark with data "#{url.valid_hook}"
      if _mark is missing value
        return "Failed to create bookmark for #{url}"
      else
        invoke on _mark
        return ""
      end if
    end tell
    APPLESCRIPT`.strip
    raise result unless result.empty?
  end

  # Select from a menu of available hooks and open using macOS `open`.
  def open_linked(url)
    marks = get_hooks(url)
    if marks.empty?
      warn "No hooks found for #{url}"
    else
      res = select_hook(marks)
      res.each {|mark|
        `open '#{mark[:url]}'`
      }
    end
  end

  # Link 2 or more files/urls with bi-directional hooks.
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

  # Copy all hooks from source file to target file
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

  # Delete all hooked files/urls from target file
  def delete_all_hooks(url, force: false)
    unless force
      STDERR.print "Are you sure you want to delete ALL hooks from #{url} (y/N)? "
      res = STDIN.gets.strip
    end

    if res =~ /^y/i || force
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

  # Delete hooks between two files/urls
  def delete_hooks(args, opts)
    urls = args.map(&:valid_hook).delete_if { |url| !url }
    output = []
    if opts[:all]
      urls.each_with_index do |url, i|
        raise "Invalid target: #{args[i]}" unless url

        output.push(delete_all_hooks(url, force: opts[:force]))
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

  # Create bi-directional links between every file/url in the list of arguments
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

  # Get a list of all hooks on a file/url.
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
        result.push({ file: filename, links: output.join(separator) }) if output
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

  # Output an array of hooks in the given format.
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
      warn 'No bookmarks'
    end

    output
  end

  def encode(string)
    result = `osascript <<'APPLESCRIPT'
tell application "Hook"
  percent encode "#{string.escape_quotes}"
end tell
APPLESCRIPT`.strip.gsub(/'/,'%27')
    print result
  end

  def decode(string)
    result = `osascript <<'APPLESCRIPT'
tell application "Hook"
  percent decode "#{string.escape_quotes}"
end tell
APPLESCRIPT`.strip
    print result
  end
end
