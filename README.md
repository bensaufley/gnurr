# Linte

Runs ESLint, SCSS-Lint, HAML-Lint, and Rubocop and returns info relevant to changed lines as reported by git.

## Installation

Add this line to your application's Gemfile:

```sh
gem 'linte', group: :development, require :false
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install linte
```

If you intend to use [ESLint], be sure to [install that in npm][npm-install].
The other linters – [HAML-Lint], [Rubocop], and [SCSS-Lint] – are all listed as
gem dependencies.

## Usage

```rb
linte = Linte::Processor.new(options)
# Options:
# branch: base branch to diff (default: master)
# linters: which linters to run (default: es,haml,ruby,scss (all))
# verbose: turn on verbose mode
linte.execute
```

## Contributing

1. Fork it ( https://github.com/bensaufley/linte/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[ESLint]: http://eslint.org
[HAML-Lint]: https://github.com/brigade/haml-lint
[Rubocop]: https://github.com/bbatsov/rubocop
[SCSS-Lint]: https://github.com/brigade/scss-lint
[npm-install]: http://eslint.org/docs/user-guide/getting-started
