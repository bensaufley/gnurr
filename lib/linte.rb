require 'linte/version'
require 'json'
require 'colorize'
require 'awesome_print'

# Main module for Linte gem
module Linte
  # Base linter class from which each linter extends
  class Linter
    def initialize(files)
      @files = Hash[files.select { |file, _lines| File.extname(file) == @spec[:extension] }]
      @messages = {} if @files.empty?
      relevant_messages
    end

    def format_errors
      puts_line_diffs if @options[:verbose]
      return if relevant_messages.empty?
      puts "#{left_bump(2)}Messages:"
      relevant_messages.each do |filename, messages|
        messages.each do |message|
          puts left_bump(3) + format_error(filename, message)
        end
      end
      relevant_messages
    end

    def format_error(filename, message)
      filename.colorize(color: @spec[:color]) + ':' +
        format_line(message) + ' ' +
        format_severity(message) + ' ' +
        message[:message] +
        format_linter(message)
    end

    def errors(json)
      return [] unless json && !json.empty?
      json.map { |files| map_errors(files) }
          .select { |_f, messages| messages && !messages.empty? }
    end

    def puts_line_diffs
      puts "#{left_bump(2)}Lines changed:".colorize(mode: :bold)
      line_diffs.each do |filename, lines|
        puts "#{left_bump(3)}#{filename}:#{lines.join(', ').colorize(:cyan)}"
      end
    end

    def line_diffs
      Hash[
        @files.select { |file| File.extname(file) == @spec[:extension] }.map do |filename, lines|
          [filename, array_to_ranges(lines)]
        end
      ]
    end

    def relevant_messages
      @messages ||= errors(JSON.parse(`git diff --name-only --diff-filter=ACMRTUXB #{@options[:branch]} #{@files.map(&:first).join(' ')} | xargs #{@spec[:command]}`))
    rescue => e
      if @options[:stdout]
        puts "#{'ERROR'.colorize(:red)}: #{e}"
        puts e.backtrace if @options[:verbose]
      else
        warn("Error: #{e}")
      end
      @messages = {}
    end

    def pretty_print
      puts "#{left_bump}Linting #{@type.to_s.colorize(@spec[:color])}…".colorize(mode: :bold)
      format_errors || puts("#{left_bump(2)}#{"#{@type.to_s.upcase} all clear! ✔".colorize(color: :light_green)}")
      puts "#{left_bump}Done linting #{@type.to_s.colorize(@spec[:color])}\n".colorize(mode: :bold) if @options[:verbose]
    end

    private

    def array_to_ranges(array)
      array = array.compact.uniq.sort
      ranges = []
      return ranges if array.empty?
      left = array.first
      right = nil
      array.each do |obj|
        if right && obj != right.succ
          ranges << Range.new(left, right)
          left = obj
        end
        right = obj
      end
      ranges + [Range.new(left, right)]
    end

    def format_line(message)
      (message[:line].to_s + (message[:column] ? ':' + message[:column].to_s : '')).colorize(:cyan)
    end

    def format_severity(message)
      message[:severity] == :error ? '[E]'.colorize(:red) : '[W]'.colorize(:yellow)
    end

    def format_linter(message)
      message[:linter] ? " (#{message[:linter]})".colorize(:cyan) : ''
    end

    def left_bump(indent = 1)
      '▎'.ljust(indent * 2).colorize(color: @spec[:color])
    end

    def map_errors(errors)
      # Empty: filled by subclasses
    end

    def standardize(message, column, line, linter, description, severity, error)
      {
        column: message[column],
        line: message[line],
        linter: message[linter],
        message: message[description],
        severity: message[severity] == error ? :error : :warning
      }
    end
  end

  # ES/JS Linter
  class EsLinter < Linter
    def initialize(files, options)
      @options = options
      @type = :es
      @spec = {
        color: :red,
        command: 'eslint -f json',
        extension: '.js'
      }
      @pwd = `printf $(pwd)`

      super(files)
    end

    private

    def map_errors(file)
      [
        file['filePath'],
        file['messages'].map do |message|
          next unless @files[file['filePath'].sub("#{@pwd}/", '')].include?(message['line'])
          standardize(message, 'column', 'line', 'ruleId', 'message', 'severity', 2)
        end.reject(&:nil?)
      ]
    end
  end

  # Class from which Haml and Ruby extend
  class RubyBaseLinter < Linter
    def errors(json)
      super(json['files'])
    end

    private

    def map_errors(file)
      [
        file['path'],
        file['offenses'].map do |message|
          next unless @files[file['path']].include?(message['location']['line'])
          standardize(message)
        end.reject(&:nil?)
      ]
    end

    def standardize(message)
      {
        column: message['location']['column'], # nil in haml-lint
        line: message['location']['line'],
        linter: message['cop_name'], # nil in haml-lint
        message: message['message'],
        severity: message['severity'] == 'error' ? :error : :warning
      }
    end
  end

  # HAML Linter
  class HamlLinter < RubyBaseLinter
    def initialize(files, options)
      @options = options
      @type = :haml
      @spec = {
        color: :magenta,
        command: 'haml-lint -r json',
        extension: '.haml'
      }
      super(files)
    end
  end

  # Ruby Linter
  class RubyLinter < RubyBaseLinter
    def initialize(files, options)
      @options = options
      @type = :ruby
      @spec = {
        color: :yellow,
        command: 'rubocop -f json',
        extension: '.rb'
      }
      super(files)
    end
  end

  # SASS Linter
  class ScssLinter < Linter
    def initialize(files, options)
      @options = options
      @type = :scss
      @spec = {
        color: :blue,
        command: 'scss-lint -f JSON',
        extension: '.scss'
      }
      super(files)
    end

    private

    def map_errors(params)
      filename, messages = params
      [
        filename,
        messages.map do |message|
          next unless @files[filename].include?(message['line'])
          standardize(message, 'column', 'line', 'linter', 'reason', 'severity', 'error')
        end.reject(&:nil?)
      ]
    end
  end

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
