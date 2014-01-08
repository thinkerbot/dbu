module Dbu
  module Parsers
    module_function

    def lookup(parser)
      case parser
      when 'line'
        require 'dbu/parsers/line'
        Dbu::Parsers::Line
      when 'json'
        require 'dbu/parsers/json'
        Dbu::Parsers::Json
      else
        raise "unsupported parser: #{parser.inspect}"
      end
    end

  end
end
