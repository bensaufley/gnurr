module Gnurr
  # Main class for execution
  class Processor
    LINTERS = {
      es: EsLinter,
      haml: HamlLinter,
      ruby: RubyLinter,
      scss: ScssLinter
    }.freeze

    def initialize(options = {})
      if options[:linters] && options[:linters].any?
        options[:linters] = LINTERS.keys & options[:linters]
      end
      @options = {
        branch: 'master',
        expanded: false,
        linters: LINTERS.keys,
        stdout: false,
        verbose: false
      }.merge(options)
    end

    def execute
      lints = {}
      @options[:linters].each do |type|
        begin
          lints[type] = LINTERS[type].new(@options)
          lints[type].execute
        rescue => e
          lints[type] = e.inspect
        end
      end
      lints
    end
  end
end
