require 'gnurr/linters/es_linter'
require 'gnurr/linters/haml_linter'
require 'gnurr/linters/ruby_linter'
require 'gnurr/linters/scss_linter'

module Gnurr
  # Main class for execution
  class Processor
    LINTERS = {
      es: Gnurr::Linters::EsLinter,
      haml: Gnurr::Linters::HamlLinter,
      ruby: Gnurr::Linters::RubyLinter,
      scss: Gnurr::Linters::ScssLinter
    }.freeze

    def initialize(options = {})
      @options = options
      if @options[:linters] && options[:linters].any?
        @options[:linters] = LINTERS.keys & @options[:linters]
      else
        @options[:linters] = LINTERS.keys
      end
    end

    def execute
      @lints ||= {}
      @options[:linters].each do |type|
        begin
          @lints[type] = LINTERS[type].new(@options)
          @lints[type].execute
        rescue => e
          @lints[type] = e.inspect
        end
      end
      @lints
    end

    def lints
      @lints ||= {}
    end
  end
end
