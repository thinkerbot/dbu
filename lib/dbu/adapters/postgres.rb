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

        command
      end

      def command_env
        env = super
        env["PGPASSWORD"] = config.password if config.password
        env
      end

      def search_path
        config[:search_path]
      end

      def new_conn
        conn = PG::Connection.open(
          :host     => config.host,
          :dbname   => config.database,
          :port     => config.port,
          :user     => config.username,
          :password => config.password
        )
        if search_path
          conn.exec("set search_path to #{search_path}")
        end
        conn
      end

      def prepare(name, sql)
        super
        conn.prepare(name, sql)
      end

      def exec(name, args)
        super
        res = conn.exec_prepared(name, args)
        res.check
        res
      end

      def each_line(name, args, options = {})
        res = exec(name, args)

        field_sep = options[:field_sep]

        if options[:headers]
          yield res.fields.join(field_sep)
        end

        res.each_row do |row|
          yield row.join(field_sep)
        end
      end
    end
  end
end
