module Dbu
  class Parser
    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def parse(line)
      raise NotImplementedError
    end
  end
end
