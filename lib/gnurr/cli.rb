require 'colorize'
require 'gnurr/helper'

module Gnurr
  # For outputting stuff using the command-line tool
  module CLI
    include Gnurr::Helper

    def print_messages
      format_start
      format_messages || format_all_clear
      format_finish
      messages
    end

    private

    def format_all_clear
      puts "#{left_bump(2)}#{"#{type.to_s.upcase} all clear! ✔"
        .colorize(color: :light_green)}"
    end

    def format_messages
      format_line_diffs if @options[:verbose]
      return false if messages.empty?
      puts "#{left_bump(2)}Messages:".colorize(mode: :bold)
      messages.each do |filename, messages|
        messages.each do |message|
          puts format_error(filename, message)
        end
      end
      messages
    end

    def format_error(filename, message)
      left_bump(3) +
        filename.colorize(color: color) + ':' +
        format_line(message) + ' ' +
        format_severity(message) + ' ' +
        message[:message] +
        format_linter(message)
    end

    def format_expanded_notice
      if @options[:expanded]
        puts "#{left_bump(2)}Linting entire files".colorize(mode: :bold)
      end
    end

    def format_finish
      if @options[:verbose]
        puts "#{left_bump}Done linting #{type.to_s.colorize(color)}\n"
          .colorize(mode: :bold)
      else
        puts
      end
    end

    def format_line(message)
      line = message[:line].to_s
      line += ':' + message[:column].to_s if message[:column]
      line.colorize(:cyan)
    end

    def format_line_diffs
      diffs = line_diffs
      return if format_no_changes(diffs)
      puts "#{left_bump(2)}Lines changed:".colorize(mode: :bold)
      diffs.each do |filename, lines|
        puts "#{left_bump(3)}#{filename}:#{lines.join(', ').colorize(:cyan)}"
      end
      format_expanded_notice
    end

    def format_linter(message)
      message[:linter] ? " (#{message[:linter]})".colorize(:cyan) : ''
    end

    def format_no_changes(diffs)
      if diffs.empty?
        puts "#{left_bump(2)}No changes#{' at specified paths' unless @options[:path].nil?}.".colorize(mode: :bold)
        true
      end
    end

    def format_severity(message)
      if message[:severity] == :error
        '[E]'.colorize(:red)
      else
        '[W]'.colorize(:yellow)
      end
    end

    def format_start
      puts "#{left_bump}Linting #{type.to_s.colorize(color)}…"
        .colorize(mode: :bold)
    end
  end
end
