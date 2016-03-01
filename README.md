# LintTrap

![Version](https://img.shields.io/badge/Version-0.1.3-yellow.svg)
[![Code Climate](https://codeclimate.com/github/bensaufley/lint_trap/badges/gpa.svg)](https://codeclimate.com/github/bensaufley/lint_trap)
[![Test Coverage](https://codeclimate.com/github/bensaufley/lint_trap/badges/coverage.svg)](https://codeclimate.com/github/bensaufley/lint_trap/coverage)
[![Issue Count](https://codeclimate.com/github/bensaufley/lint_trap/badges/issue_count.svg)](https://codeclimate.com/github/bensaufley/lint_trap)

Runs ESLint, SCSS-Lint, HAML-Lint, and Rubocop and returns info relevant to changed lines as reported by git.

## Installation

**This gem is not yet hosted elsewhere.** To install, clone the repo, then
`cd` into that directory and build the gem.

```bash
$ git clone https://github.com/bensaufley/lint_trap
$ bundle install
…
$ rake install
```

### Eventually, you'll be able to:

Add this line to your application's Gemfile:

```bash
gem 'lint_trap', group: :development, require :false
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install lint_trap
```

If you intend to use [ESLint], be sure to [install that in npm][npm-install].
The other linters – [HAML-Lint], [Rubocop], and [SCSS-Lint] – are all listed as
gem dependencies.

## Usage

```rb
lint_trap = LintTrap::Processor.new(options)
# Options:
# branch: base branch to diff (default: master)
# linters: which linters to run (default: es,haml,ruby,scss (all))
# verbose: turn on verbose mode
lint_trap.execute
```

```sh
$ lint-trap --help
Usage: lint-trap [options]
    -b, --branch NAME                Base branch: branch to diff against (default: master)
    -l, --linters LIST               Linters to use (default: es,haml,ruby,scss (all))
    -v, --verbose                    Verbose mode (false unless specified)
    -h, --help                       Prints this help
```

## Contributing

1. Fork it ( https://github.com/bensaufley/lint_trap/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[ESLint]: http://eslint.org
[HAML-Lint]: https://github.com/brigade/haml-lint
[Rubocop]: https://github.com/bbatsov/rubocop
[SCSS-Lint]: https://github.com/brigade/scss-lint
[npm-install]: http://eslint.org/docs/user-guide/getting-started
