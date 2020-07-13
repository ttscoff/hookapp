# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__), 'lib', 'hook', 'version.rb'])
spec = Gem::Specification.new do |s|
  s.name = 'hookapp'
  s.version = Hook::VERSION
  s.author = 'Brett Terpstra'
  s.email = 'me@brettterpstra.com'
  s.homepage = 'https://brettterpstra.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A CLI for Hook.app (macOS)'
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.extra_rdoc_files = ['README.rdoc','hook.rdoc']
  s.rdoc_options << '--title' << 'hook' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'hook'
  s.add_development_dependency('rake','~> 13.0.1')
  s.add_development_dependency('rdoc','~> 6.1.2')
  s.add_development_dependency('aruba','~> 0.14.14')
  s.add_runtime_dependency('gli','2.19.0')
end
