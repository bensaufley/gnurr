require "linte/version"

module Linte
  class Linter
    FILE_TYPES = {
      es: {
        color: :red,
        command: 'eslint -f json',
        extension: '.js'
      },
      haml: {
        color: :magenta,
        command: 'haml-lint -r json',
        extension: '.haml'
      },
      ruby: {
        color: :yellow,
        command: 'rubocop -f json',
        extension: '.rb'
      },
      scss: {
        color: :blue,
        command: 'scss-lint -f JSON',
        extension: '.scss'
      }
    }

    def initialize(options)
      @options = {
        branch: 'master',
        linters: [:es, :haml, :ruby, :scss],
        verbose: false
      }.deep_merge(options)
    end

    def execute
      @pwd = `printf $(pwd)`
      file_list = get_diffs
      FILE_TYPES.each do |type, spec|
        next unless @options[:linters].include?(type)
        puts "#{left_bump(spec)}Linting #{type.to_s.colorize(spec[:color])}…".colorize(mode: :bold)
        puts "#{left_bump(spec, 1)}#{"   #{type.to_s.upcase} all clear! ✔ ".colorize(color: :light_green)}" if lint(file_list, spec, type)
        puts "#{left_bump(spec)}…done linting #{type.to_s.colorize(spec[:color])}\n".colorize(mode: :bold) if @options[:verbose]
        puts "\n"
      end
    end

    private

    def array_to_ranges(array)
      array = array.compact.uniq.sort
      ranges = []
      if !array.empty?
        # Initialize the left and right endpoints of the range
        left, right = array.first, nil
        array.each do |obj|
          # If the right endpoint is set and obj is not equal to right's successor
          # then we need to create a range.
          if right && obj != right.succ
            ranges << Range.new(left,right)
            left = obj
          end
          right = obj
        end
        ranges << Range.new(left,right)
      end
      ranges
    end

    def get_diffs
      Hash[
        `git diff #{@options[:branch]} --name-only --diff-filter=ACMRTUXB`.split("\n")
          .map { |file|
            [
              file,
              `git diff --unified=0 #{@options[:branch]} #{file} | egrep '\\+[0-9]+(,[1-9][0-9]*)? ' | perl -pe 's/^.+\\+([0-9]+)(,([0-9]+))? .+$/\"$1-\".($1+$3)/e'`
                .split("\n")
                .map { |lines| Range.new(*lines.split('-').map(&:to_i)) }
                .map(&:to_a)
                .flatten
            ]
        }.select { |_k, v| v && !v.empty? }
      ]
    end

    def left_bump(spec, indent=1)
      '▎'.ljust(indent*2).colorize(color: spec[:color])
    end

    def get_es_errors(json, files)
      json.map do |file|
        [
          file['filePath'],
          file['messages'].select do |message|
            if files[file['filePath'].sub(@pwd + '/', '')].include?(message['line'])
              {
                column: message['column'],
                line: message['line'],
                linter: message['ruleId'],
                message: message['message'],
                severity: message['severity'] == 2 ? :error : :warning
              }
            end
          end.reject(&:nil?)
        ]
      end.select { |_f, messages| messages && !messages.empty? }
    end

    def get_scss_errors(json, files)
      json.map do |filename, messages|
        [
          filename,
          messages.map do |message|
            if files[filename].include?(message['line'])
              {
                column: message['column'],
                line: message['line'],
                linter: message['linter'],
                message: message['reason'],
                severity: message['severity'] == 'error' ? :error : :warning
              }
            end
          end.reject(&:nil?)
        ]
      end.select { |_f, messages| messages && !messages.empty? }
    end

    def get_rb_errors(json, files)
      json['files'].map do |file|
        [
          file['path'],
          file['offenses'].select do |message|
            if files[file['path']].include?(message['line'])
              {
                column: message['location']['column'], # nil in haml-lint
                line: message['location']['line'],
                linter: message['cop_name'], # nil in haml-lint
                message: message['message'],
                severity: message['severity'] == 'error' ? :error : :warning
              }
            end
          end.reject(&:nil?)
        ]
      end.select { |_f, messages| messages && !messages.empty? }
    end

    def get_relevant_errors(json, type, files)
      Hash[
        case type
          when :es
            get_es_errors(json, files)
          when :scss
            get_scss_errors(json, files)
          else # ruby and haml
            get_rb_errors(json, files)
        end
      ]
    end

    def format_errors(errors, files, spec)
      if @options[:verbose]
        puts "#{left_bump(spec, 2)}Lines changed:".colorize(mode: :bold)
        files.select { |file| File.extname(file) == spec[:extension] }.each do |filename, lines|
          puts "#{left_bump(spec,3)}#{filename}:#{array_to_ranges(lines).join(',').colorize(:cyan)}"
        end
      end
      puts "#{left_bump(spec,2)}Messages:" unless errors.empty?
      errors.each do |filename, messages|
        messages.each do |message|
          puts left_bump(spec,3) +
            filename.colorize(color: spec[:color]) + ':' +
            (message[:line].to_s + (':' + message[:column].to_s if message[:column])).colorize(:cyan) + ' ' +
            (message[:severity] == :error ? '[E]'.colorize(:red) : '[W]'.colorize(:yellow)) + ' ' +
            message[:message] +
            (" (#{message[:linter]})".colorize(:cyan) if message[:linter])
        end
      end
      errors.empty?
    end

    def lint_files(files, spec, type)
      relevant_files = files.select { |file| File.extname(file) == spec[:extension] }.map(&:first)
      lint = %x(git diff --name-only --diff-filter=ACMRTUXB #{@options[:branch]} #{relevant_files.join(' ')} | xargs #{spec[:command]})
      lint = JSON.parse(lint)
      errors = get_relevant_errors(lint, type, files)
      format_errors(errors, files, spec)
    end
  end
end
