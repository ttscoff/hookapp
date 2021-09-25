require 'hook-helpers'
require 'test_helper'

class CloneTest < Test::Unit::TestCase
  include HookHelpers

  def setup
    @basedir = HOOK_FILES_DIR
    create_temp_files
  end

  def teardown
    clean_temp_files
  end

  def test_clone
    count = 3

    files = Dir.glob(File.join(HOOK_FILES_DIR, '*.md'))

    # Link all files to last file
    hook('link', *files[0..count - 1])
    links = hook('ls', files[count - 1]).strip

    hook('clone', files[count-1], files[count])
    cloned_links = hook('ls', files[count]).strip

    assert_match(links, cloned_links, "#{files[count - 1]} links should match #{files[count]} links")
  end
end
