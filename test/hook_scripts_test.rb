require 'hook-helpers'
require 'test_helper'

class ScriptsTest < Test::Unit::TestCase
  include HookHelpers

  def setup
  end

  def teardown
  end

  def test_shell_scripts
    %w[bash fish zsh].each do |sh|
      source = IO.read(File.join(HOOK_COMPLETIONS_DIR, 'hook_completion.' + sh))
      result = hook('scripts', sh)
    
      assert_match(source, result, 'Script output should match')
    end
  end
end
