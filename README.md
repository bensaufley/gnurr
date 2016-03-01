# Linte

Runs ESLint, SCSS-Lint, HAML-Lint, and Rubocop and returns info relevant to changed lines as reported by git.

## Installation

Add this line to your application's Gemfile:

    gem 'linte'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install linte

## Usage

    linte = Linte::Linter.new(options)
    # Options:
    # branch: base branch to diff (default: master)
    # linters: which linters to run (default: es,haml,ruby,scss (all))
    # verbose: turn on verbose mode

## Contributing

1. Fork it ( https://github.com/bensaufley/linte/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
