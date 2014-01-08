require 'dbu/parser'
require 'json'

module Dbu
  module Parsers
    class Json < Parser
      def parse(line)
        JSON.parse(line)
      end
    end
  end
end
