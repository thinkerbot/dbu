require 'dbu/parser'

module Dbu
  module Parsers
    class Line < Parser
      def field_sep
        @field_sep = options.fetch(:field_sep, ',')
      end

      def parse(line)
        line.strip.split(field_sep)
      end

      def parse_hash(line)
        args = parse(line)
        Hash[signature.zip(args)]
      end
    end
  end
end
