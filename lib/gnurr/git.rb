require 'gnurr/helper'

module Gnurr
  # For handling/reading Git output
  module Git
    include Gnurr::Helper

    private

    def extract_lines(diffs)
      diffs.map do |lines|
        nums = lines.match(/^.+\+(?<from>[0-9]+)(,(?<len>[0-9]+))? .+$/)
        Range.new(nums[:from].to_i, nums[:from].to_i + nums[:len].to_i)
      end.map(&:to_a).flatten
    end

    def full_file_diff
      return @diff if @diff
      path = @options[:path].nil? || !@options[:path].any? ? '' : "-- #{@options[:path].join(' ')}"
      diff = `git diff #{@options[:base]} --name-only --diff-filter=ACMRTUXB #{path}`
               .split("\n")
               .map { |file| [file, file_diffs(file)] }
      @diff = Hash[diff.select { |_k, v| v && v.any? }]
    end

    def file_diffs(file)
      diffs = `git diff --unified=0 #{@options[:base]} #{escaped_filename(file)} \
              | egrep '\\+[0-9]+(,[1-9][0-9]*)? '`
      extract_lines(diffs.split("\n"))
    end
  end
end
