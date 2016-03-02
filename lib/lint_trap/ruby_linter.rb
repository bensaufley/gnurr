require 'lint_trap/ruby_base_linter'

module LintTrap
  # Ruby Linter
  class RubyLinter < RubyBaseLinter
    def initialize(files, options)
      @type = :ruby
      @eligible_files = `rubocop -L`.split("\n")
      @spec = {
        color: :yellow,
        command: 'rubocop -f json',
        filter: ->(file) { @eligible_files.include?(file) }
      }
      super(files, options)
    end
  end
end
