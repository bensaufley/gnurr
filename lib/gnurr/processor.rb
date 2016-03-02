module Gnurr
  # Main class for execution
  class Processor
    LINTERS = {
      es: EsLinter,
      haml: HamlLinter,
      ruby: RubyLinter,
      scss: ScssLinter
    }.freeze

    def initialize(options)
      if options[:linters] && !options[:linters].empty?
        options[:linters] = LINTERS.keys & options[:linters]
      end
      @options = {
        branch: 'master',
        linters: LINTERS.keys,
        stdout: false,
        verbose: false
      }.merge(options)
    end

    def execute
      lints = {}
      @options[:linters].each do |type|
        lints[type] = LINTERS[type].new(diffs, @options)
        lints[type].pretty_print if @options[:stdout]
      end
      lints
    end

    private

    def extract_line_sets(diffs)
      diffs.map do |lines|
        nums = lines.match(/^.+\+(?<from>[0-9]+)(,(?<len>[0-9]+))? .+$/)
        Range.new(nums[:from].to_i, nums[:from].to_i + nums[:len].to_i)
      end.map(&:to_a).flatten
    end

    def line_diffs(file)
      diffs = `git diff --unified=0 #{@options[:branch]} #{file} | egrep '\\+[0-9]+(,[1-9][0-9]*)? '`.split("\n")
      extract_line_sets(diffs)
    end

    def diffs
      return @diff if @diff
      diff = `git diff #{@options[:branch]} --name-only --diff-filter=ACMRTUXB`
             .split("\n")
             .map { |file| [file, line_diffs(file)] }
      @diff = Hash[diff.select { |_k, v| v && !v.empty? }]
    end
  end
end
