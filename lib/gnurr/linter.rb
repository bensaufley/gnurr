require 'json'

require 'gnurr/helper'
require 'gnurr/cli'
require 'gnurr/git'

module Gnurr
  # Base linter class from which each linter extends
  class Linter
    include Gnurr::Helper
    include Gnurr::CLI
    include Gnurr::Git

    attr_reader :errors

    def initialize(options)
      @errors = []
      @options = {
        base: 'master',
        expanded: false,
        stdout: false,
        verbose: false,
        path: nil
      }.merge(options)
      raise "Dependency not available for #{type}" unless requirements_met?
    rescue => e
      log_error(e)
    end

    def execute
      @options[:stdout] ? print_messages : messages
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
      JSON.parse(run_command("#{command} #{escaped_files.join(' ')}"))
    rescue => e
      log_error(e)
      {}
    end

    def violation_count
      messages.map(&:last).flatten.length
    end

    private

    def escaped_files
      files.map do |file, _lines|
        escaped_filename(file)
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

    def relative_filename(filename)
      filename
    end

    def requirements_met?
      false # Can't lint from base class
    end

    def standardize_message(_message)
      raise 'Can\'t standardize on base Linter class'
    end

    def run_command(command)
      output, err = Open3.capture3(command)
      @errors << err unless err.nil? || err.length == 0
      output
    end
  end
end
