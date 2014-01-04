require 'dbu/query'

module Dbu
  class QueryBuilder
    class << self
      def build_from(file)
        name = File.basename(file, ".rb")
        text = File.read(file)
        builder = new(name)
        builder.instance_eval(text)
        builder.to_query
      end
    end

    attr_reader :options

    def initialize(name = nil)
      @options = {:name => name}
    end

    def desc(str)
      options[:desc] = str
    end

    def help(str)
      options[:help] = str
    end

    def args(*args)
      if args.length == 1 && args.first.kind_of?(Hash)
        args = args.first
      end
      options[:args] = args
    end

    def vars(*vars)
      if vars.length == 1 && vars.first.kind_of?(Hash)
        vars = vars.first
      end
      options[:vars] = vars
    end

    def before(sql)
      options[:before_sql] = sql
    end

    def query(sql)
      options[:sql] = sql
    end

    def after(sql)
      options[:after_sql] = sql
    end

    def to_query
      Query.create(options)
    end
  end
end
