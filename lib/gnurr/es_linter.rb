require 'gnurr/linter'

module Gnurr
  # ES/JS Linter
  class EsLinter < Linter
    def type
      :es
    end

    def color
      :red
    end

    def command
      'eslint -f json'
    end

    def filter(file)
      File.extname(file) == '.js'
    end

    private

    def map_errors(file)
      [
        file['filePath'],
        file['messages'].map do |message|
          next unless @files[file['filePath'].sub("#{pwd}/", '')].include?(message['line'])
          standardize(message, 'column', 'line', 'ruleId', 'message', 'severity', 2)
        end.reject(&:nil?)
      ]
    end

    def pwd
      @pwd ||= `printf $(pwd)`
    end
  end
end
