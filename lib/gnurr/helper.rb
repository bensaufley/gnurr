require 'colorize'

module Gnurr
  # Miscellaneous helper methods for the gem
  module Helper
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

    def escaped_filename(filename)
      filename.gsub(/(\s)/,'\\\\\1')
    end

    def left_bump(indent = 1)
      '▎'.ljust(indent * 2).colorize(color: color)
    end

    def log_error(e)
      if @options[:stdout]
        puts "#{'ERROR'.colorize(:red)}: #{e}"
        puts e.backtrace if @options[:verbose]
      else
        warn("Error: #{e}")
      end
    end
  end
end
