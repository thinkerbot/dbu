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

      def prepare_sql(sql, args = [])
        argh = {}
        args.each_with_index {|arg, i| argh[arg] = "$#{i + 1}" }
        [sql % argh, args]
      end

      def prepare(name, sql)
        super
        if preview?
          preview_target.puts "prepare #{escape(name)} as\n#{sql}"
        else
          conn.prepare(name, sql)
        end
      end

      def exec_prepared(name, args)
        super
        if preview?
          @last_result = nil
          vars = args.map {|arg| escape_literal(arg) }
          preview_target.puts "execute #{escape(name)}(#{vars.join(', ')});"
          []
        else
          @last_result = conn.exec_prepared(name, args)
          @last_result.check
          @last_result.enum_for(:each_row)
        end
      end

      def deallocate(name)
        super
        exec "deallocate #{escape(name)}"
      end

      def exec(sql)
        super
        if preview?
          @last_result = nil
          preview_target.puts sql
          []
        else
          @last_result = conn.exec(sql)
          @last_result.check
          @last_result.enum_for(:each_row)
        end
      end

      def run(name, *args)
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
