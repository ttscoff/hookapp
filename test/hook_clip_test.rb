require 'hook-helpers'
require 'test_helper'

class ClipTest < Test::Unit::TestCase
  include HookHelpers

  def setup
    @basedir = HOOK_FILES_DIR
    create_temp_files
  end

  def teardown
    clean_temp_files
  end

  def test_clip
    file = Dir.glob(File.join(HOOK_FILES_DIR, '*.md'))[0]
    # Clear clipboard
    `echo -n | pbcopy`
    hook('clip', file)
    clipboard = `pbpaste`.strip
    assert_match(/^hook:.*?#{File.basename(file).sub(/\./, '(%2E|\.)')}$/, clipboard, 'Clipboard should contain link to first file')
  end
end
