require 'lint_trap/linter'

module LintTrap
  # SASS Linter
  class ScssLinter < Linter
    def initialize(files, options)
      @type = :scss
      @spec = {
        color: :blue,
        command: 'scss-lint -f JSON',
        filter: ->(file) { File.extname(file) == '.scss' }
      }
      super(files, options)
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
