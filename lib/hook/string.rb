# frozen_string_literal: true

# String helpers
class String
  def nil_if_missing
    if self =~ /missing value/
      return nil
    else
      self
    end
  end

  def split_hook
    elements = split(/\|\|/)
    {
      name: elements[0].nil_if_missing,
      url: elements[1].nil_if_missing,
      path: elements[2].nil_if_missing
    }
  end

  def split_hooks
    split(/\^\^/).map(&:split_hook)
  end

  def valid_hook
    if File.exist?(self)
      File.expand_path(self)
    elsif self =~ /^\[.*?\]\((.*?)\)$/
      mdlink = $1
      mdlink.valid_hook
    else
      self
    end
  end

  def valid_hook!
    replace valid_hook
  end

  # Capitalize only if no uppercase
  def cap
    if self !~ /[A-Z]/
      capitalize
    else
      self
    end
  end

  def cap!
    replace cap
  end

  def clip
    res = `/bin/echo -n #{Shellwords.escape(self)} | pbcopy`.strip
    raise 'Failed to copy to clipboard' unless res.empty?

    true
  end
end
