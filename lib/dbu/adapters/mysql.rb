require 'mysql'
require 'dbu/adapter'

module Dbu
  module Adapters
    class Mysql < Adapter
      def initialize(*args)
        super
        @prepared_statements = {}
      end

      def command_args(options = {})
        command = ["mysql", "-h", config.host, "-P", config.port, "-u", config.username, config.database]

        if options[:stream]
          if options[:field_sep] != "\t"
            raise "mysql does not support setting a non-tab field sep"
          end
          command += ["--batch", "--skip-column-names"]
        end

        if options[:headers]
          command += ["--column-names"]
        end

        if options[:echo]
          command += ["-v"]
        end

        if options[:mode] == 'preview'
          command += ["-p"]
        end

        command
      end

      def command_env
        env = super
        env["MYSQL_PWD"] = config.password if config.password
        env
      end

      def new_conn
        ::Mysql.connect(config.host, config.username, config.password, config.database, config.port)
      end

      def prepare(name, sql)
        super
        @prepared_statements[name] = conn.prepare(sql)
      end

      def exec_prepared(name, args)
        super
        statement = @prepared_statements[name] or raise "no such prepared statement: #{name.inspect}"
        @last_result = statement.execute(*args)
        @last_result.enum_for(:each)
      end

      def exec(sql)
        super
        @last_result = conn.query(sql)
        @last_result.enum_for(:each)
      end

      def escape(str)
        conn.escape_string(str)
      end

      def escape_literal(str)
        "'#{escape(str)}'"
      end

      def last_headers
        last_result.fields.map(&:name)
      end

      def deallocate(name)
        super
        @prepared_statements.delete(name)
      end
    end
  end
end
