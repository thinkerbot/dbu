require 'dbu/parser'
require 'json'

module Dbu
  module Parsers
    class Json < Parser
      def parse(line)
        argh = parse_hash(line)
        signature.map {|key| argh[key.to_s] }
      end

      def parse_hash(line)
        JSON.parse(line)
      end
    end
  end
end
