module Dbu
  class Query
    attr_reader :name
    attr_reader :base
    attr_reader :signature

    def initialize(name, base, *signature)
      @name = name
      @base = base
      @signature = signature
    end

    def adapter
      @adapter or raise("no adapter is bound")
    end

    def bind(adapter)
      @adapter = adapter
    end

    def exec(args)
      raise NotImplementedError
    end

    def exec_hash(argh)
      raise NotImplementedError
    end

    def unbind
      @adapter = nil
    end

    def preview
      base
    end

    def parser(options = {})
      input_format = options[:input_format]
      case input_format
      when :line
        require 'dbu/parsers/line'
        Dbu::Parsers::Line.new(signature, options)
      when :json
        require 'dbu/parsers/json'
        Dbu::Parsers::Json.new(signature, options)
      else
        raise "unknown input format: #{input_format.inspect}"
      end
    end
  end
end
