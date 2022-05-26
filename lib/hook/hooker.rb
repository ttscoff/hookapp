# frozen_string_literal: true

# Hook.app CLI interface
class Hooker < HookApp

  def initialize
    super
    warn "Using Hooker class is deprecated, update to use HookApp instead"
  end
end
