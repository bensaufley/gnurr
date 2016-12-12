require 'gnurr/linters/es_linter'
require 'gnurr/linters/haml_linter'
require 'gnurr/linters/ruby_linter'
require 'gnurr/linters/scss_linter'

module Gnurr
  # Main class for execution
  class Processor
    include Gnurr::Helper

    LINTERS = {
      es: Gnurr::Linters::EsLinter,
      haml: Gnurr::Linters::HamlLinter,
      ruby: Gnurr::Linters::RubyLinter,
      scss: Gnurr::Linters::ScssLinter
    }.freeze

    attr_reader :violation_count

    def initialize(options = {})
      @options = options
      @violation_count = 0
      @files = []
      if @options[:linters] && options[:linters].any?
        @options[:linters] = LINTERS.keys & @options[:linters]
      else
        @options[:linters] = LINTERS.keys
      end
    end

    def execute
      @lints ||= {}
      @violation_count = 0
      @options[:linters].each do |type|
        lint_type(type)
      end
      if @options[:stdout]
        print 'Total Violations: '.colorize(mode: :bold)
        puts @violation_count.to_s.colorize(mode: :bold, color: severity_color(@violation_count, @files.length))
      end
      @lints
    end

    def lint_type(type)
      @lints[type] = LINTERS[type].new(@options)
      @lints[type].execute
      @violation_count += @lints[type].violation_count
      (@files += @lints[type].files.keys).uniq!
    rescue => e
      log_error(e)
      @lints[type] = e
    end

    def lints
      @lints ||= {}
    end
  end
end
