module Dbu
  class Adapter
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def command_args(options = {})
      raise NotImplementedError
    end

    def command_env
      {}
    end
  end
end
