# Gnurr

### _n._ The substance that collects over time in the bottoms of pockets or cuffs of trousers; pocket lint.

[![Gem Version](https://badge.fury.io/rb/gnurr.svg)](https://badge.fury.io/rb/gnurr)
[![Code Climate](https://codeclimate.com/github/bensaufley/gnurr/badges/gpa.svg)](https://codeclimate.com/github/bensaufley/gnurr)
[![Test Coverage](https://codeclimate.com/github/bensaufley/gnurr/badges/coverage.svg)](https://codeclimate.com/github/bensaufley/gnurr/coverage)
[![Issue Count](https://codeclimate.com/github/bensaufley/gnurr/badges/issue_count.svg)](https://codeclimate.com/github/bensaufley/gnurr)

Runs ESLint, SCSS-Lint, HAML-Lint, and Rubocop and returns info relevant to changed lines as reported by git.

## Installation

**This gem is not yet hosted elsewhere.** To install, clone the repo, then
`cd` into that directory and build the gem.

```bash
$ git clone https://github.com/bensaufley/gnurr
$ bundle install
…
$ rake install
```

If you intend to use [ESLint], be sure to [install that in npm][npm-install].
The other linters – [HAML-Lint], [Rubocop], and [SCSS-Lint] – are all listed as
gem dependencies.

As this gem is built to work with your git diffs, it does also require git.
If you've managed to execute the above code, you're already there.

### Eventually, you'll be able to:

Add this line to your application's Gemfile:

```bash
gem 'gnurr', group: :development, require :false
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install gnurr
```

## Usage

In Ruby:

```rb
gnurr = Gnurr::Processor.new(options)
# Options:
# branch: base branch to diff (default: master)
# linters: which linters to run (default: es,haml,ruby,scss (all))
# verbose: turn on verbose mode
gnurr.execute
```

In your shell:

```sh
$ gnurr --help
Usage: gnurr [options]
    -b, --branch NAME                Base branch: branch to diff against (default: master)
    -l, --linters LIST               Linters to use (default: es,haml,ruby,scss (all))
    -v, --verbose                    Verbose mode (false unless specified)
    -h, --help                       Prints this help
```

## Contributing

1. Fork it ( https://github.com/bensaufley/gnurr/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[ESLint]: http://eslint.org
[HAML-Lint]: https://github.com/brigade/haml-lint
[Rubocop]: https://github.com/bbatsov/rubocop
[SCSS-Lint]: https://github.com/brigade/scss-lint
[npm-install]: http://eslint.org/docs/user-guide/getting-started
