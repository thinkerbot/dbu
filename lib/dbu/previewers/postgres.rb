require 'dbu/previewer'

module Dbu
  module Previewers
    module Postgres
      include Previewer

      def _prepare_(name, sql)
        super
        io.puts "prepare #{escape(name)} as\n#{sql}"
      end

      def _exec_prepared_(name, args)
        @last_result = nil
        vars = args.map {|arg| escape_literal(arg) }
        io.puts "execute #{escape(name)}(#{vars.join(', ')});"
        []
      end

      def _exec_(sql)
        @last_result = nil
        io.puts sql
        []
      end

      def _deallocate_(name)
        io.puts "deallocate #{escape(name)};"
      end
    end
  end
end
