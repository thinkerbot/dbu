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

      def prepare_sql(sql, args = [])
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

      def prepare(name, sql)
        super
        if preview?
          lines = sql.lines.map {|line| escape(line.chomp("\n")) }
          preview_target.puts "prepare #{escape(name)} from '\n#{lines.join("\n")}\n';"
        else
          @prepared_statements[name] = conn.prepare(sql)
        end
      end

      def exec_prepared(name, args = [])
        super
        if preview?
          @last_result = nil
          vars = []
          args.each_with_index do |arg, i|
            preview_target.puts "set @v#{i+1} = #{escape_literal(arg)};"
            vars << "@v#{i+1}"
          end
          preview_target.puts "execute #{escape(name)} using #{vars.join(', ')};"
          []
        else
          statement = @prepared_statements[name] or raise "no such prepared statement: #{name.inspect}"
          @last_result = statement.execute(*args)
          @last_result.enum_for(:each)
        end
      end

      def deallocate(name)
        super
        @prepared_statements.delete(name)
        exec "deallocate prepare #{escape(name)}"
      end

      def exec(sql)
        super
        if preview?
          @last_result = nil
          preview_target.puts sql
          []
        else
          @last_result = conn.query(sql)
          @last_result.enum_for(:each)
        end
      end

      def run(name, args = [])
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
