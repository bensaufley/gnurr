module LintTrap
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

    def line_diffs(file)
      `git diff --unified=0 #{@options[:branch]} #{file} | egrep '\\+[0-9]+(,[1-9][0-9]*)? ' | perl -pe 's/^.+\\+([0-9]+)(,([0-9]+))? .+$/\"$1-\".($1+$3)/e'`
        .split("\n")
        .map { |lines| Range.new(*lines.split('-').map(&:to_i)) }
        .map(&:to_a)
        .flatten
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
