# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gnurr/version'

Gem::Specification.new do |spec|
  spec.name          = 'gnurr'
  spec.version       = Gnurr::VERSION
  spec.authors       = ['Ben Saufley']
  spec.email         = ['contact@bensaufley.com']
  spec.summary       = 'Diff-specific linter'
  spec.description   = 'Runs ESLint, SCSS-Lint, HAML-Lint, and Rubocop and returns info relevant to changed lines as reported by git.'
  spec.homepage      = 'http://github.com/bensaufley/gnurr'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.requirements += [
    'git',
    'npm and eslint for JS linting',
    'haml_lint for Ruby linting',
    'scss_lint for SCSS linting',
    'rubocop for Ruby linting'
  ]

  spec.required_ruby_version = '~> 2.3.0'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'git', '~> 1.3.0'
  spec.add_development_dependency 'colorize'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'haml_lint', '~> 0.16.1'
  spec.add_development_dependency 'scss_lint', '~> 0.47.0'
  spec.add_development_dependency 'rubocop', '~> 0.37.2'

  spec.add_runtime_dependency 'colorize'
end
