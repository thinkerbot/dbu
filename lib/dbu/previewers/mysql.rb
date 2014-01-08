require 'dbu/previewer'

module Dbu
  module Previewers
    module Mysql
      include Previewer

      def _prepare_(name, sql)
        lines = sql.lines.map {|line| escape(line.chomp("\n")) }
        io.puts "prepare #{escape(name)} from '\n#{lines.join("\n")}\n';"
      end

      def _exec_prepared_(name, args = [])
        @last_result = nil
        vars = []
        args.each_with_index do |arg, i|
          io.puts "set @v#{i+1} = #{escape_literal(arg)};"
          vars << "@v#{i+1}"
        end
        io.puts "execute #{escape(name)} using #{vars.join(', ')};"
        []
      end

      def _exec_(sql)
        @last_result = nil
        io.puts sql
        []
      end

      def _deallocate_(name)
        io.puts "deallocate prepare #{escape(name)};"
      end
    end
  end
end
