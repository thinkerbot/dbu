module Dbu
  class Config
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def adapter_name
      options['dbu']
    end

    def adapter_class
      case adapter_name
      when 'postgres'
        require 'dbu/adapters/postgres'
        Dbu::Adapters::Postgres
      when 'mysql'
        require 'dbu/adapters/mysql'
        Dbu::Adapters::Mysql
      else
        raise "unsupported dbu database: #{adapter_name.inspect}"
      end
    end

    def adapter
      @adapter ||= adapter_class.new(self)
    end

    def host
      options['host']
    end

    def database
      options['database']
    end

    def port
      options['port']
    end

    def username
      options['username']
    end

    def password
      options['password']
    end
  end
end
