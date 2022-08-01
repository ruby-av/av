# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'av/version'

Gem::Specification.new do |spec|
  spec.name          = 'av'
  spec.version       = Av::VERSION
  spec.authors       = ['Omar Abdel-Wahab']
  spec.email         = ['owahab@gmail.com']
  spec.summary       = 'Programmable Ruby interface for FFMPEG/Libav'
  spec.description   = 'Programmable Ruby interface for FFMPEG/Libav'
  spec.homepage      = 'https://github.com/ruby-av'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rails'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-rspec'

  spec.add_dependency 'terrapin'
end
