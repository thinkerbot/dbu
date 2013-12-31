require 'dbu/query'

module Dbu
  module Queries
    class Interpolated < Query
      def exec(args)
        argh = Hash[signature.zip(args)]
        exec_hash(argh)
      end

      def exec_hash(argh)
        adapter.exec(base % argh)
      end
    end
  end
end
