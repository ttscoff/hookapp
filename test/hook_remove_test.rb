require 'hook-helpers'
require 'test_helper'

class RemoveTest < Test::Unit::TestCase
  include HookHelpers

  def setup
    @basedir = HOOK_FILES_DIR
    create_temp_files
  end

  def teardown
    clean_temp_files
  end

  def test_remove
    count = 5

    files = Dir.glob(File.join(HOOK_FILES_DIR, '*.md'))[0..(count - 1)]

    # Link all files to last file
    hook('link', *files)

    assert_count_links(files[-1], count - 1, "Last file should start with #{count - 1} links")

    hook('remove', files[-1], files[0])
    
    assert_count_links(files[-1], count - 2, "Last file should have #{count - 2} links")

    hook('remove', '--all', '--force', files[-1])

    assert_count_links(files[-1], 0, "Last file should end with 0 links")
  end
end
