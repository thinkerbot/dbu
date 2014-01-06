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
      @conn ||= _new_conn_
    end

    def prepare(name, sql, args = [])
      sql, signature = _prepare_sql_(sql, args)
      logger.info { "prepare #{name} #{sql.inspect}" }
      _prepare_(name, sql)
      signature
    end

    def exec_prepared(name, args = [])
      logger.info { "exec #{name} #{args.inspect}" }
      _exec_prepared_(name, args)
    end

    def deallocate(name)
      logger.info { "deallocate #{name}" }
      _deallocate_(name)
    end

    def exec(sql)
      logger.info { "exec #{sql.inspect}" }
      _exec_(sql)
    end

    def run(name, args = [])
      logger.info { "run #{name} #{args.inspect}" }
      _run_(name, args)
    end

    def _new_conn_
      raise NotImplementedError
    end

    def _prepare_sql_(sql, args)
      raise NotImplementedError
    end

    def _prepare_(name, sql)
      raise NotImplementedError
    end

    def _exec_prepared_(name, args)
      raise NotImplementedError
    end

    def _deallocate_(name)
      raise NotImplementedError
    end

    def _exec_(sql)
      raise NotImplementedError
    end

    def _run_(sql, args)
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
  end
end
