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

      def exec(name, args)
        super
        statement = @prepared_statements[name] or raise "no such prepared statement: #{name.inspect}"
        statement.execute(*args)
      end

      def each_line(name, args, options = {})
        res = exec(name, args)

        field_sep = options[:field_sep]

        if options[:headers]
          yield res.fields.map(&:name).join(field_sep)
        end

        res.each do |row|
          yield row.join(field_sep)
        end
      end
    end
  end
end
