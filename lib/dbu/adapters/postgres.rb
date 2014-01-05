require 'pg'
require 'dbu/adapter'

module Dbu
  module Adapters
    class Postgres < Adapter
      def command_args(options = {})
        command = ["psql", "-h", config.host, "-p", config.port, "-U", config.username, "-d", config.database]

        if options[:stream]
          command += ["--no-align", "--field-separator", options[:field_sep], "--tuples-only", "--quiet"]
        end

        if options[:headers]
          command -= ["--tuples-only"]
          command += ["--pset=footer=off"]
        end

        if options[:echo]
          command += ["--echo-all"]
        end

        command
      end

      def command_env
        env = super
        env["PGPASSWORD"] = config.password if config.password
        env
      end

      def new_conn
        conn = PG::Connection.open(
          :host     => config.host,
          :dbname   => config.database,
          :port     => config.port,
          :user     => config.username,
          :password => config.password
        )
        conn
      end

      def prepare(name, sql)
        super
        conn.prepare(name, sql)
      end

      def exec_prepared(name, args)
        super
        @last_result = conn.exec_prepared(name, args)
        @last_result.check
        @last_result.enum_for(:each_row)
      end

      def exec(sql)
        super
        @last_result = conn.exec(sql)
        @last_result.check
        @last_result.enum_for(:each_row)
      end

      def last_headers
        last_result.fields
      end

      def escape(str)
        conn.escape(str)
      end

      def escape_literal(str)
        conn.escape_literal(str)
      end

      def deallocate(name)
        super
      end
    end
  end
end
