require 'hook-helpers'
require 'test_helper'

class LinkTest < Test::Unit::TestCase
  include HookHelpers

  def setup
    @basedir = HOOK_FILES_DIR
    create_temp_files
  end

  def teardown
    clean_temp_files
  end

  def test_link
    count = 3

    files = Dir.glob(File.join(HOOK_FILES_DIR, '*.md'))[0..(count - 1)]

    # Link all files to last file
    hook('link', *files)

    assert_count_links(files[-1], count - 1, "Last file should have #{count - 1} links")
    assert_count_links(files[0], 1, 'First file should have 1 link')
  end

  def test_bi_link
    count = 3

    files = Dir.glob(File.join(HOOK_FILES_DIR, '*.md'))[0..(count - 1)]

    # Link all files bi-directionally
    hook('link', '-a', *files)

    assert_count_links(files[-1], count - 1, "Last file should have #{count - 1} links")
    assert_count_links(files[0], count - 1, "First file should have #{count - 1} links")
  end
end
