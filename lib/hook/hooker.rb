# frozen_string_literal: true

# String helpers
class String
  def split_hook
    elements = split(/\|\|/)
    {
      name: elements[0],
      url: elements[1],
      path: elements[2]
    }
  end

  def split_hooks
    split(/\^\^/).map(&:split_hook)
  end

  def valid_hook
    if File.exist?(self)
      File.expand_path(self)
    elsif self =~ /^(hook|http)/
      self
    else
      if self =~ /^\[.*?\]\((.*?)\)$/
        mdlink = $1
        mdlink.valid_hook
      else
        false
      end
    end
  end

  def valid_hook!
    replace valid_hook
  end
end

# Hook.app CLI interface
class Hooker
  def initialize(global_args)
    @global_args = global_args
  end

  def validate_format(fmt, options)
    valid_format_rx = options.map { |fmt| fmt.sub(/^(.)(.*)$/, '^\1(\2)?$') }
    valid_format = false
    valid_format_rx.each_with_index do |rx, i|
      cmp = Regexp.new(rx, 'i')
      next unless fmt =~ cmp
      valid_format = options[i]
      break
    end
    return valid_format
  end

  def bookmark_for(url)
    url.valid_hook!
    raise "Invalid target: #{url}" unless url

    mark = `osascript <<'APPLESCRIPT'
      tell application "Hook"
        set _hook to bookmark from URL "#{url}"
        return title of _hook & "||" & address of _hook & "||" & path of _hook
      end tell
    APPLESCRIPT`.strip
    mark.split_hook
  end

  def get_hooks(url)
    url.valid_hook!
    raise "Invalid target: #{url}" unless url

    hooks = `osascript <<'APPLESCRIPT'
      tell application "Hook"
        set _mark to bookmark from URL "#{url}"
        if _mark is {} then return ""
        set _hooks to bookmarks hooked to _mark
        set _out to {}
        repeat with _hook in _hooks
          set _out to _out & (title of _hook & "||" & address of _hook & "||" & path of _hook)
        end repeat
        set {astid, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "^^"}
        set _output to _out as string
        set AppleScript's text item delimiters to astid
        return _output
      end tell
    APPLESCRIPT`.strip
    hooks.split_hooks
  end

  def copy_bookmark(url, opts)
    mark = bookmark_for(url)
    output = if opts[:markdown]
               "[#{mark[:name]}](#{mark[:url]})"
             else
               mark[:url]
             end
    `/bin/echo -n #{Shellwords.escape(output)} | pbcopy`
    %(Copied #{opts[:markdown] ? 'Markdown link' : 'Hook URL'} for '#{mark[:name]}' to clipboard)
  end

  def select_hook(marks)
    intpad = marks.length.to_s.length + 1
    marks.each_with_index do |mark, i|
      STDERR.printf "%#{intpad}d) %s\n", i + 1, mark[:name]
    end
    STDERR.print 'Open which bookmark: '
    sel = STDIN.gets.strip.to_i
    if sel.positive? && sel <= marks.length
      marks[sel - 1]
    else
      warn 'Invalid selection'
      Process.exit 1
    end
  end

  def open_gui(url)
    `osascript <<'APPLESCRIPT'
    tell application "Hook"
      set _mark to bookmark from URL "#{url.valid_hook}"
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
          set _mark1 to bookmark from URL "#{file}"
          set _mark2 to bookmark from URL "#{target}"
          hook together _mark1 and _mark2
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
            set _mark1 to bookmark from URL "#{hook[:url]}"
            set _mark2 to bookmark from URL "#{target}"
            hook together _mark1 and _mark2
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
            set _mark1 to bookmark from URL "#{hook[:url]}"
            set _mark2 to bookmark from URL "#{url}"
            remove hook between _mark1 and _mark2
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
          set _mark1 to bookmark from URL "#{source}"
          set _mark2 to bookmark from URL "#{target}"
          remove hook between _mark1 and _mark2
          return true
        end tell
      APPLESCRIPT`
      return "Hook removed between #{source} and #{target}"
    else
      raise "Invalid number of URLs or files specified"

    end
  end

  def link_all(args)
    args.each do |file|
      source = file.valid_hook
      link_to = args.dup.map(&:valid_url).reject { |url|
        url == source
      }
      link_to.each do |url|
        `osascript <<'APPLESCRIPT'
          tell application "Hook"
            set _mark1 to bookmark from URL "#{source}"
            set _mark2 to bookmark from URL "#{url}"
            hook together _mark1 and _mark2
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

      if !hooks_arr.empty?
        hooks_arr.reject! { |h| h[:path].nil? || h[:path] == '' } if opts[:files_only]

        output = []

        case opts[:format]
        when /^m/
          hooks_arr.each do |h|
            output.push("- [#{h[:name]}](#{h[:url]})")
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
    result.join(separator)
  end
end
