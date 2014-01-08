module Dbu
  module Adapters
    module_function

    def lookup(adapter_name)
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

  end
end
