require 'fileutils'
require 'open3'

class ::Numeric
  def pad_to(x)
    "%0#{x.to_i}d" % self
  end
end

module HookHelpers
  HOOK_EXEC = File.join(File.dirname(__FILE__), '..', '..', 'bin', 'hook')
  HOOK_FILES_DIR = File.join(File.dirname(__FILE__), '..', 'hookfiles')
  HOOK_COMPLETIONS_DIR = File.join(File.dirname(__FILE__), '..', '..', 'lib', 'completion')

  def create_temp_files
    FileUtils.mkdir_p HOOK_FILES_DIR
    10.times.with_index do |i|
      new_file = File.join(HOOK_FILES_DIR, i.pad_to(2) + '.md')
      File.open(new_file, 'w') do |f|
        f.puts ("Hook Test File ##{i}")
      end
      hook('rm', '-a', '-f', new_file)
    end
  end

  def clean_temp_files
    FileUtils.rm_r HOOK_FILES_DIR, force: true
  end

  def assert_count_links(file, count, msg)
    res = hook('ls', file).strip

    links = res == 'No bookmarks' ? 0 : res.split(/\n/).size

    assert_equal(count, links, msg)
  end

  def assert_links_include(file, pattern, msg)
    result = hook('ls', file).strip
    assert_match(/#{pattern}/, result, msg)
  end

  def hook(*args)
    hook_with_env({}, *args)
  end

  def hook_with_stdin(input, *args)
    pread_stdin({}, input, HOOK_EXEC, *args)
  end

  def hook_with_env(env, *args)
    pread(env, HOOK_EXEC, *args)
  end

  def pread_stdin(env, input, *cmd)
    out, err, status = Open3.capture3(env, 'bundle', 'exec', *cmd, :stdin_data => input)
    unless status.success?
      raise [
        "Error (#{status}): #{cmd.inspect} failed", "STDOUT:", out.inspect, "STDERR:", err.inspect
      ].join("\n")
    end

    out
  end

  def pread(env, *cmd)
    out, err, status = Open3.capture3(env, 'bundle', 'exec', *cmd)
    unless status.success?
      raise [
        "Error (#{status}): #{cmd.inspect} failed", "STDOUT:", out.inspect, "STDERR:", err.inspect
      ].join("\n")
    end

    out
  end
end
