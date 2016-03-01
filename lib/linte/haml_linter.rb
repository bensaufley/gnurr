require 'linte/ruby_base_linter'

module Linte
  # HAML Linter
  class HamlLinter < RubyBaseLinter
    def initialize(files, options)
      @options = options
      @type = :haml
      @spec = {
        color: :magenta,
        command: 'haml-lint -r json',
        extension: '.haml'
      }
      super(files)
    end
  end
end
