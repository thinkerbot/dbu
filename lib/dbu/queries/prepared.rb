require 'dbu/query'

module Dbu
  module Queries
    class Prepared < Query
      def bind(adapter)
        super
        adapter.prepare(name, base)
      end

      def exec(args)
        adapter.exec_prepared(name, args)
      end

      def exec_hash(argh)
        args = signature.map {|key| argh[key] }
        exec(args)
      end

      def unbind
        adapter.deallocate(name)
        super
      end
    end
  end
end
