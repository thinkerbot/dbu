module Dbu
  class Parser
    attr_reader :signature
    attr_reader :options

    def initialize(signature, options = {})
      @signature = signature
      @options = options
    end

    def parse(line)
      raise NotImplementedError
    end

    def parse_hash(line)
      raise NotImplementedError
    end
  end
end
