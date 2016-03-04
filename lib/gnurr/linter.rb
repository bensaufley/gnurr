require 'gnurr/helper'
require 'gnurr/cli'
require 'gnurr/git'

module Gnurr
  # Base linter class from which each linter extends
  class Linter
    include Gnurr::Helper
    include Gnurr::CLI
    include Gnurr::Git

    def initialize(options)
      @options = options
      raise "Dependency not available for #{type}" unless requirements_met?
    rescue => e
      log_error(e)
    end

    def execute
      @options[:stdout] ? print_messages : messages
    end

    def parse_messages(json)
      return [] unless json.any?
      msgs = json.map { |f| map_errors(f) }
                 .select { |_f, m| m && m.any? }
      if @options[:expanded]
        msgs.to_a
      else
        filter_messages(msgs)
      end
    end

    def files
      @files ||= Hash[full_file_diff.select { |file, _lines| filter(file) }]
    end

    def filter_messages(messages)
      messages.map do |filename, msgs|
        msgs.reject! do |msg|
          !files[relative_filename(filename)].include?(msg[:line])
        end
        msgs.empty? ? nil : [filename, msgs]
      end.reject(&:nil?)
    end

    def full_range(filename)
      [Range.new(1, `wc -l < #{filename}`.to_i + 1)]
    end

    def line_diffs
      Hash[
        files.map do |filename, lines|
          [
            filename,
            @options[:expanded] ? full_range(filename) : array_to_ranges(lines)
          ]
        end
      ]
    end

    def relevant_messages
      return {} if files.empty?
      JSON.parse(`#{command} #{escaped_files.join(' ')}`)
    rescue => e
      log_error(e)
      {}
    end

    private

    def escaped_files
      files.map do |file, _lines|
        file.sub(/(\s)/, '\\\\\1')
      end
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

    def relative_filename(filename)
      filename
    end

    def requirements_met?
      true # Set by subclasses
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
