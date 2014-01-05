require 'logging'

module Dbu
  class Adapter
    attr_reader :config
    attr_reader :logger
    attr_reader :last_result
    attr_reader :preview_target

    def initialize(config = {}, logger = nil)
      @config = config
      @logger = logger || Logging.logger[self]
      @last_result = nil
      @preview_target = nil
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

    def prepare_sql(sql, args = [])
      raise NotImplementedError
    end

    def prepare(name, sql)
      logger.info { "prepare #{name} #{sql.inspect}" }
    end

    def exec_prepared(name, args = [])
      logger.info { "exec #{name} #{args.inspect}" }
    end

    def deallocate(name)
      logger.info { "deallocate #{name}" }
    end

    def exec(sql)
      logger.info { "exec #{sql.inspect}" }
    end

    def run(name, args = [])
      raise NotImplementedError
    end

    def escape(str)
      raise NotImplementedError
    end

    def escape_literal(str)
      raise NotImplementedError
    end

    def last_headers
      raise NotImplementedError
    end

    def preview_to(io)
      @preview_target = io
    end

    def preview?
      @preview_target.nil? ? false : true
    end
  end
end
