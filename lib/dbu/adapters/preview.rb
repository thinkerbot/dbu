require 'dbu/adapter'

module Dbu
  module Adapters
    class Preview < Adapter
      attr_reader :target

      def initialize(*args)
        super
        @target = config.fetch(:target, [])
      end

      def exec(sql)
        super
        target << sql
      end

      def escape(str)
        str.to_s
      end

      def escape_literal(str)
        str.to_s
      end
    end
  end
end
