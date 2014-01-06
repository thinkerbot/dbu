require 'pg'
require 'dbu/adapter'

module Dbu
  module Adapters
    class Postgres < Adapter
      def command_args(options = {})
        command = ["psql", "-h", config.host, "-p", config.port, "-U", config.username, "-d", config.database, "-v", "ON_ERROR_STOP=on"]

        if options[:stream]
          command += ["--no-align", "--field-separator", options[:field_sep], "--tuples-only", "--quiet"]
        end

        if options[:headers]
          command -= ["--tuples-only"]
          command += ["--pset=footer=off"]
        end

        if options[:echo]
          command -= ["--quiet"]
          command += ["--echo-all"]
        end

        command
      end

      def command_env
        env = super
        env["PGPASSWORD"] = config.password if config.password
        env
      end

      def _new_conn_
        conn = PG::Connection.open(
          :host     => config.host,
          :dbname   => config.database,
          :port     => config.port,
          :user     => config.username,
          :password => config.password
        )
        conn
      end

      def _prepare_sql_(sql, args)
        argh = {}
        args.each_with_index {|arg, i| argh[arg] = "$#{i + 1}" }
        [sql % argh, args]
      end

      def _prepare_(name, sql)
        conn.prepare(name, sql)
      end

      def _exec_prepared_(name, args)
        @last_result = conn.exec_prepared(name, args)
        @last_result.check
        @last_result.enum_for(:each_row)
      end

      def _deallocate_(name)
        exec "deallocate #{escape(name)}"
      end

      def _exec_(sql)
        @last_result = conn.exec(sql)
        @last_result.check
        @last_result.enum_for(:each_row)
      end

      def _run_(name, args)
        exec "select #{escape(name)}(#{args.map {|arg| escape_literal(arg) }.join(', ')});"
      end

      def escape(str)
        conn.escape(str.to_s)
      end

      def escape_literal(str)
        conn.escape_literal(str.to_s)
      end

      def last_headers
        last_result ? last_result.fields : []
      end
    end
  end
end
