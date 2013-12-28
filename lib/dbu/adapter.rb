module Dbu
  class Adapter
    attr_reader :config
    attr_reader :logger

    def initialize(config)
      @config = config
      @logger = Logging.logger[self]
    end

    def command_args(options = {})
      raise NotImplementedError
    end

    def command_env
      {}
    end

    def conn
      @conn ||= new_conn
    end

    def new_conn
      raise NotImplementedError
    end

    def prepare(name, sql)
      logger.info { "prepare #{name} #{sql.inspect}" }
    end

    def exec(name, args)
      logger.info { "exec #{name} #{args.inspect}" }
    end

    def each_line(name, args, options = {})
    end
  end
end
