require 'gnurr/helper'
require 'gnurr/cli'

module Gnurr
  # Base linter class from which each linter extends
  class Linter
    include Gnurr::Helper
    include Gnurr::CLI

    def initialize(files, options)
      raise "Dependency not available for #{type}" unless requirements_met?
      @options = options
      @files = Hash[files.select { |file, _lines| filter(file) }]
      @messages = {} if @files.empty?
    rescue => e
      log_error(e)
    end

    def execute
      @options[:stdout] ? print_messages : messages
    end

    def parse_messages(json)
      return [] unless json.any?
      messages = json.map { |files| map_errors(files) }
                     .select { |_f, msgs| msgs && msgs.any? }
      if @options[:expanded]
        messages
      else
        filter_messages(messages)
      end
    end

    def filter_messages(messages)
      messages.map do |filename, msgs|
        msgs.reject! { |msg| !@files[filename].include?(msg[:line]) }
        msgs.empty? ? nil : [filename, msgs]
      end.reject(&:nil?)
    end

    def line_diffs
      Hash[
        @files.map do |filename, lines|
          [filename, array_to_ranges(lines)]
        end
      ]
    end

    def relevant_messages
      JSON.parse(`git diff --name-only --diff-filter=ACMRTUXB \
                 #{@options[:branch]} #{@files.map(&:first).join(' ')} \
                 | xargs #{command}`)
    rescue => e
      log_error(e)
      {}
    end

    private

    def requirements_met?
      true # Set by subclasses
    end

    def map_errors(file)
      [
        file_path(file),
        file_messages(file).map do |message|
          standardize_message(message)
        end.reject(&:nil?)
      ]
    end

    def messages
      @messages ||= parse_messages(relevant_messages)
    end

    def standardize_message(message)
      {
        column: message['column'],
        line: message['line'],
        linter: message['linter'],
        message: message['message'],
        severity: message['severity'] == 'error' ? :error : :warning
      }
    end
  end
end
