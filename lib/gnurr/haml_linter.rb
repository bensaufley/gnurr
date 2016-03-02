require 'gnurr/ruby_base_linter'

module Gnurr
  # HAML Linter
  class HamlLinter < RubyBaseLinter
    def type
      :haml
    end

    def color
      :magenta
    end

    def command
      'haml-lint -r json'
    end

    def filter(file)
      File.extname(file) == '.haml'
    end
  end
end
