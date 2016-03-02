module Gnurr
  # Base linter class from which each linter extends
  class Linter
    def initialize(files, options)
      @options = options
      @files = Hash[files.select { |file, _lines| filter(file) }]
      @messages = {} if @files.empty?
      relevant_messages
    end

    def format_errors
      puts_line_diffs if @options[:verbose]
      return if relevant_messages.empty?
      puts "#{left_bump(2)}Messages:".colorize(mode: :bold)
      relevant_messages.each do |filename, messages|
        messages.each do |message|
          puts left_bump(3) + format_error(filename, message)
        end
      end
      relevant_messages
    end

    def format_error(filename, message)
      filename.colorize(color: color) + ':' +
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
      diffs = line_diffs
      if diffs.empty?
        puts "#{left_bump(2)}No changes.".colorize(mode: :bold)
      else
        puts "#{left_bump(2)}Lines changed:".colorize(mode: :bold)
        diffs.each do |filename, lines|
          puts "#{left_bump(3)}#{filename}:#{lines.join(', ').colorize(:cyan)}"
        end
      end
    end

    def line_diffs
      Hash[
        @files.map do |filename, lines|
          [filename, array_to_ranges(lines)]
        end
      ]
    end

    def relevant_messages
      @messages ||= errors(JSON.parse(`git diff --name-only --diff-filter=ACMRTUXB #{@options[:branch]} #{@files.map(&:first).join(' ')} | xargs #{command}`))
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
      puts "#{left_bump}Linting #{type.to_s.colorize(color)}…".colorize(mode: :bold)
      format_errors || puts("#{left_bump(2)}#{"#{type.to_s.upcase} all clear! ✔".colorize(color: :light_green)}")
      puts "#{left_bump}Done linting #{type.to_s.colorize(color)}\n".colorize(mode: :bold) if @options[:verbose]
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
      '▎'.ljust(indent * 2).colorize(color: color)
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
end
