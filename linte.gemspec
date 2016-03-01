# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'linte/version'

Gem::Specification.new do |spec|
  spec.name          = 'linte'
  spec.version       = Linte::VERSION
  spec.authors       = ['Ben Saufley']
  spec.email         = ['contact@bensaufley.com']
  spec.summary       = %q{Diff-specific linter}
  spec.description   = %q{Runs ESLint, SCSS-Lint, HAML-Lint, and Rubocop and returns info relevant to changed lines as reported by git.}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.requirements  += %w(npm eslint)

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'colorize'
  spec.add_development_dependency 'awesome_print'

end
