require 'gnurr/linter'

module Gnurr
  module Linters
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

      def file_path(file)
        file['filePath']
      end

      def file_messages(file)
        file['messages']
      end

      def relative_filename(filename)
        filename.sub(%r{^#{pwd}/}, '')
      end

      def requirements_met?
        !`eslint -v`.nil?
      rescue
        false
      end

      def pwd
        @pwd ||= `printf $(pwd)`
      end

      def standardize_message(message)
        {
          column: message['column'],
          line: message['line'],
          linter: message['ruleId'],
          message: message['message'],
          severity: message['severity'] == 2 ? :error : :warning
        }
      end
    end
  end
end
