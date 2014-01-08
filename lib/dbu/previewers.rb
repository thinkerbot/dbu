module Dbu
  module Previewers
    module_function

    def lookup(adapter_name)
      case adapter_name
      when 'postgres'
        require 'dbu/previewers/postgres'
        Dbu::Previewers::Postgres
      when 'mysql'
        require 'dbu/previewers/mysql'
        Dbu::Previewers::Mysql
      else
        raise "preview unavailable for dbu database: #{adapter_name.inspect}"
      end
    end

  end
end
