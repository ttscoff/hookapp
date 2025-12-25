# frozen_string_literal: true

# Ensure we require the local version and not one we might have installed already
require './lib/hook/version'
Gem::Specification.new do |s|
  s.name = 'hookapp'
  s.version = Hook::VERSION
  s.author = 'Brett Terpstra'
  s.email = 'me@brettterpstra.com'
  s.homepage = 'https://brettterpstra.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A CLI for Hook.app (macOS)'
  s.license = 'MIT'
  # Use git ls-files if available, otherwise fall back to Dir glob
  s.files = begin
    if File.directory?('.git') && system('git rev-parse --git-dir > /dev/null 2>&1')
      `git ls-files`.split("\n").reject(&:empty?)
    else
      Dir.glob('**/*').select { |f| File.file?(f) && !f.start_with?('.') && !f.include?('/.') }
    end
  end
  s.require_paths = ['lib']
  s.extra_rdoc_files = ['README.rdoc', 'hook.rdoc']
  s.rdoc_options << '--title' << 'hook' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'hook'
  s.required_ruby_version = '>= 2.6.0'
  s.add_development_dependency('aruba', '~> 0.14.14')
  s.add_development_dependency('rake', '~> 13.0.1')
  s.add_development_dependency('rdoc', '~> 6.3.2')
  s.add_runtime_dependency('gli', '~> 2.20.1')
  s.add_runtime_dependency('tty-which', '~> 0.5', '>= 0.5.0')
end
