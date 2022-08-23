# frozen_string_literal: true

module Hook
  module PromptSTD
    ##
    ## Clear the terminal screen
    ##
    def clear_screen(msg = nil)
      puts "\e[H\e[2J" if $stdout.tty?
      puts msg unless msg.nil?
    end

    ##
    ## Redirect STDOUT and STDERR to /dev/null or file
    ##
    ## @param      file  [String] a file path to redirect to
    ##
    def silence_std(file = '/dev/null')
      $stdout = File.new(file, 'w')
      $stderr = File.new(file, 'w')
    end

    ##
    ## Restore silenced STDOUT and STDERR
    ##
    def restore_std
      $stdout = STDOUT
      $stderr = STDERR
    end
  end

  # Methods for working installing/using FuzzyFileFinder
  module PromptFZF
    ##
    ## Get path to fzf binary, installing if needed
    ##
    ## @return     [String] Path to fzf binary
    ##
    def fzf
      @fzf ||= install_fzf
    end

    ##
    ## Remove fzf binary
    ##
    def uninstall_fzf
      fzf_bin = File.join(File.dirname(__FILE__), '../helpers/fzf/bin/fzf')
      FileUtils.rm_f(fzf_bin) if File.exist?(fzf_bin)
      warn 'fzf: removed #{fzf_bin}'
    end

    ##
    ## Return the path to the fzf binary
    ##
    ## @return     [String] Path to fzf
    ##
    def which_fzf
      fzf_dir = File.join(File.dirname(__FILE__), '../helpers/fzf')
      fzf_bin = File.join(fzf_dir, 'bin/fzf')
      return fzf_bin if File.exist?(fzf_bin)

      TTY::Which.which('fzf')
    end

    ##
    ## Install fzf on the current system. Installs to a
    ## subdirectory of the gem
    ##
    ## @param      force  [Boolean] If true, reinstall if
    ##                    needed
    ##
    ## @return     [String] Path to fzf binary
    ##
    def install_fzf(force: false)
      if force
        uninstall_fzf
      elsif which_fzf
        return which_fzf
      end

      fzf_dir = File.join(File.dirname(__FILE__), '../helpers/fzf')
      FileUtils.mkdir_p(fzf_dir) unless File.directory?(fzf_dir)
      fzf_bin = File.join(fzf_dir, 'bin/fzf')
      return fzf_bin if File.exist?(fzf_bin)

      warn 'fzf: Compiling and installing fzf -- this will only happen once'
      warn 'fzf: fzf is copyright Junegunn Choi, MIT License <https://github.com/junegunn/fzf/blob/master/LICENSE>'

      silence_std
      `'#{fzf_dir}/install' --bin --no-key-bindings --no-completion --no-update-rc --no-bash --no-zsh --no-fish &> /dev/null`
      unless File.exist?(fzf_bin)
        restore_std
        warn 'Error installing, trying again as root'
        silence_std
        `sudo '#{fzf_dir}/install' --bin --no-key-bindings --no-completion --no-update-rc --no-bash --no-zsh --no-fish &> /dev/null`
      end
      restore_std
      unless File.exist?(fzf_bin)
        puts 'fzf: unable to install fzf. You can install manually and Hook CLI will use the system version.'
        puts 'fzf: see https://github.com/junegunn/fzf#installation'
        raise RuntimeError.new('Error installing fzf, please report at https://github.com/ttscoff/hookapp/issues')
      end

      warn "fzf: installed to #{fzf}"
      fzf_bin
    end
  end

  module Prompt
    include PromptSTD
    include PromptFZF
  end
end
