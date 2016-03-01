require 'lint_trap/linter'

module LintTrap
  # Class from which Haml and Ruby extend
  class RubyBaseLinter < Linter
    def errors(json)
      super(json['files'])
    end

    private

    def map_errors(file)
      [
        file['path'],
        file['offenses'].map do |message|
          next unless @files[file['path']].include?(message['location']['line'])
          standardize(message)
        end.reject(&:nil?)
      ]
    end

    def standardize(message)
      {
        column: message['location']['column'], # nil in haml-lint
        line: message['location']['line'],
        linter: message['cop_name'], # nil in haml-lint
        message: message['message'],
        severity: message['severity'] == 'error' ? :error : :warning
      }
    end
  end
end
