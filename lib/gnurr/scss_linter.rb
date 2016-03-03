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

    def file_path(params)
      params[0]
    end

    def file_messages(params)
      params[1]
    end

    def requirements_met?
      Gem::Specification.find_all_by_name('scss_lint').any?
    end

    def standardize_message(message)
      {
        column: message['column'],
        line: message['line'],
        linter: message['linter'],
        message: message['reason'],
        severity: message['severity'] == 'error' ? :error : :warning
      }
    end
  end
end
