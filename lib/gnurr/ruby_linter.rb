require 'gnurr/ruby_base_linter'

module Gnurr
  # Ruby Linter
  class RubyLinter < RubyBaseLinter
    def type
      :ruby
    end

    def color
      :yellow
    end

    def command
      'rubocop -f json'
    end

    def filter(file)
      eligible_files.include?(file)
    end

    def eligible_files
      @eligible_files ||= `rubocop -L`.split("\n")
    end

    private

    def requirements_met?
      Gem::Specification.find_all_by_name('rubocop').any?
    end
  end
end
