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
          lints[type] = LINTERS[type].new(git_diffs, @options)
          lints[type].execute
        rescue => e
          lints[type] = e.inspect
        end
      end
      lints
    end

    private

    def git_diffs
      return @diff if @diff
      diff = `git diff #{@options[:branch]} --name-only --diff-filter=ACMRTUXB`
             .split("\n")
             .map { |file| [file, file_diffs(file)] }
      @diff = Hash[diff.select { |_k, v| v && v.any? }]
    end

    def file_diffs(file)
      diffs = `git diff --unified=0 #{@options[:branch]} #{file} \
              | egrep '\\+[0-9]+(,[1-9][0-9]*)? '`
      line_diffs(diffs.split("\n"))
    end

    def line_diffs(diffs)
      diffs.map do |lines|
        nums = lines.match(/^.+\+(?<from>[0-9]+)(,(?<len>[0-9]+))? .+$/)
        Range.new(nums[:from].to_i, nums[:from].to_i + nums[:len].to_i)
      end.map(&:to_a).flatten
    end
  end
end
