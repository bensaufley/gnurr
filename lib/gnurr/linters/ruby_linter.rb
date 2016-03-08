require 'gnurr/linters/ruby_based_linters'

module Gnurr
  module Linters
    # Ruby Linter
    class RubyLinter < Linter
      include Gnurr::Linters::RubyBasedLinters

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
end
