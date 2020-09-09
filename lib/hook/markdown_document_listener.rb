require 'stringio'
require 'time'

module HookApp
  class MarkdownDocumentListener

    def initialize(global_options, options, arguments, app)
      @io = File.new("README.md",'w')
      @nest = '#'
      @arg_name_formatter = GLI::Commands::HelpModules::ArgNameFormatter.new
    end

    def beginning
    end

    # Called when processing has completed
    def ending
      @io.puts
      @io.puts "Documentation generated #{Time.now.strftime('%Y-%m-%d %H:%M')}"
      @io.puts
      @io.close
    end

    # Gives you the program description
    def program_desc(desc)
      @io.puts "# Hook CLI"
      @io.puts
      @io.puts desc
      @io.puts
    end

    def program_long_desc(desc)
      @io.puts "> #{desc}"
      @io.puts
    end

    # Gives you the program version
    def version(version)
      @io.puts "*v#{version}*"
      @io.puts
      # Hacking in the basics file
      @io.puts IO.read('BASICS.md')
      @io.puts
    end

    def options
      if @nest.size == 1
        @io.puts "## Global Options"
      else
        @io.puts "#{@nest}# Options"
      end
    end

    # Gives you a flag in the current context
    def flag(name, aliases, desc, long_desc, default_value, arg_name, must_match, _type)
      invocations = ([name] + Array(aliases)).map { |_| "`" + add_dashes(_) + "`" }.join(' | ')
      usage = "#{invocations} #{arg_name || 'arg'}"
      @io.puts "#{@nest}## #{usage}"
      @io.puts
      @io.puts String(desc).strip
      @io.puts "*Default Value:* `#{default_value || 'None'}`"
      @io.puts "*Must Match:* `#{must_match.to_s}`" unless must_match.nil?
      @io.puts
      @io.puts "> " + String(long_desc).strip
      @io.puts
    end

    # Gives you a switch in the current context
    def switch(name, aliases, desc, long_desc, negatable)
      if negatable
        name = "[no-]#{name}" if name.to_s.length > 1
        aliases = aliases.map { |_|  _.to_s.length > 1 ? "[no-]#{_}" : _ }
      end
      invocations = ([name] + aliases).map { |_| "`" + add_dashes(_) + "`" }.join('|')
      @io.puts "#{@nest}## #{invocations}"
      @io.puts
      @io.puts String(desc).strip
      @io.puts
      cmd_desc = String(long_desc).strip
      @io.puts "> #{cmd_desc}\n\n" unless cmd_desc.length == 0
      @io.puts
    end

    def end_options
    end

    def commands
      @io.puts "#{@nest}# Commands"
      @io.puts
      @nest = "#{@nest}#"
    end

    # Gives you a command in the current context and creates a new context of this command
    def command(name,aliases,desc,long_desc,arg_name,arg_options)
      arg_name_fmt = @arg_name_formatter.format(arg_name, arg_options, [])
      @io.puts "#{@nest}# `$ hook` <mark>`#{([name] + aliases).join('|')}`</mark> `#{arg_name_fmt}`"
      @io.puts
      @io.puts "*#{String(desc).strip}*"
      @io.puts
      cmd_desc = String(long_desc).strip.split("\n").map { |_| "> #{_}" }.join("\n")
      @io.puts "#{cmd_desc}\n\n" unless cmd_desc.length == 0
      @nest = "#{@nest}#"
    end

    # Ends a command, and "pops" you back up one context
    def end_command(_name)
      @nest.gsub!(/\#$/, '')
      @io.puts "\n* * * * * *\n"
    end

    # Gives you the name of the current command in the current context
    def default_command(name)
      @io.puts "### [Default Command] #{name}" unless name.nil?
    end

    def end_commands
      @nest.gsub!(/\#$/, '')
    end

    private

    def add_dashes(name)
      name = "-#{name}"
      name = "-#{name}" if name.length > 2
      name
    end
  end
end

GLI::Commands::Doc::FORMATS['markdown'] = HookApp::MarkdownDocumentListener
