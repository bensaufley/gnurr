require 'gnurr/linter'

module Gnurr
  # SASS Linter
  class ScssLinter < Linter
    def type
      :scss
    end

    def color
      :blue
    end

    def command
      'scss-lint -f JSON'
    end

    def filter(file)
      File.extname(file) == '.scss'
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
end
