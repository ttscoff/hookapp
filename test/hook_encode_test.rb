require 'hook-helpers'
require 'test_helper'

class EncodeTest < Test::Unit::TestCase
  include HookHelpers

  def setup
  end

  def teardown
  end

  # # FIXME: I don't know why this isn't getting output
  # def test_encode_args
  #   result = hook('percent', 'encode', %(here's a "string?"))
  #   assert_match(/here%27s%20a%20%22string%3F%22/, result, 'URL encoded string should match')
  # end

  def test_encode_stdin
    result = pread_stdin({}, %(here's a "string?"), HOOK_EXEC, 'percent', 'encode')
    assert_match(/here%27s%20a%20%22string%3F%22/, result, 'URL encoded string should match')
  end

  def test_encode_decode_stdin
    original_string = %(here's a "string?")
    encoded = pread_stdin({}, original_string, HOOK_EXEC, 'percent', 'encode')
    decoded = pread_stdin({}, encoded, HOOK_EXEC, 'percent', 'decode')
    assert_match(decoded, original_string, 'URL encoded string should match')
  end
end
