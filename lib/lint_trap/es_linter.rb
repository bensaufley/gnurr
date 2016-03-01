require 'lint_trap/linter'

module LintTrap
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
end
