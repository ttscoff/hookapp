require 'hook-helpers'
require 'test_helper'

class ListTest < Test::Unit::TestCase
  include HookHelpers

  def setup
    @basedir = HOOK_FILES_DIR
    create_temp_files
  end

  def teardown
    clean_temp_files
  end

  def test_list
    count = 2
    files = Dir.glob(File.join(HOOK_FILES_DIR, '*.md'))[0..(count - 1)]
    # Link all files to last file
    hook('link', *files)

    assert_count_links(files[-1], count - 1, "Last file should have #{count - 1} links")
    assert_links_include(files[-1], File.basename(files[0]), 'Links on last file should include first file')
  end
end
