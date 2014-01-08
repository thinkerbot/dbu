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

      def _new_conn_
        ::Mysql.connect(config.host, config.username, config.password, config.database, config.port)
      end

      def _prepare_sql_(sql, args)
        argh = {}
        args.each {|arg| argh[arg] = "\n<:::#{arg}:::>\n" }
        signature_sql = sql % argh

        signature = \
        signature_sql.split("\n").map do |line|
          line =~ /^<:::(\w+):::>$/ ? $1.to_sym : nil
        end.compact

        argh = {}
        signature.each {|arg| argh[arg] = "?" }
        [sql % argh, signature]
      end

      def _prepare_(name, sql)
        @prepared_statements[name] = conn.prepare(sql)
      end

      def _exec_prepared_(name, args)
        statement = @prepared_statements[name] or raise "no such prepared statement: #{name.inspect}"
        @last_result = statement.execute(*args)
        @last_result.enum_for(:each)
      end

      def _deallocate_(name)
        # I don't know if it is sufficient to let the prepared statement be
        # gc'd to deallocate.  Sending a 'deallocate' exec resulted in an
        # error suggesting the statement hadn't actually been prepared...
        @prepared_statements.delete(name)
      end

      def _exec_(sql)
        @last_result = conn.query(sql)
        @last_result.enum_for(:each)
      end

      def _run_(name, args)
        exec "call #{escape(name)}(#{args.map {|arg| escape_literal(arg) }.join(', ')});"
      end

      def escape(str)
        conn.escape_string(str.to_s)
      end

      def escape_literal(str)
        "'#{escape(str)}'"
      end

      def last_headers
        last_result ? last_result.fields.map(&:name) : []
      end
    end
  end
end
