module Dbu
  class Query
    class << self
      def create(options = {})
        options = options.dup
        options[:args] = normalize_args(options[:args])
        options[:vars] = normalize_vars(options[:vars])
        new(options)
      end

      def normalize_args(obj)
        case obj
        when Hash  then obj
        when Array then Hash[obj.zip([])]
        when nil   then {}
        else raise "could not coerce to query args: #{obj.inspect}"
        end
      end

      def normalize_vars(obj)
        case obj
        when Hash  then obj
        when Array then Hash[obj.zip([])]
        when nil   then {}
        else raise "could not coerce to query vars: #{obj.inspect}"
        end
      end
    end

    attr_reader :name
    attr_reader :desc
    attr_reader :help
    attr_reader :before_sql
    attr_reader :after_sql
    attr_reader :args
    attr_reader :vars

    def initialize(options = {})
      @name = options.fetch(:name, 'anon')
      @desc = options.fetch(:desc, nil)
      @help = options.fetch(:help, nil)
      @before_sql = options.fetch(:before_sql, nil)
      @sql        = options.fetch(:sql, '')
      @after_sql  = options.fetch(:after_sql, nil)
      @args       = options.fetch(:args, {})
      @vars       = options.fetch(:vars, {})
      @originals  = [@before_sql, @sql, @after_sql]
    end

    def signature
      @signature || args.keys
    end

    def adapter
      @adapter or raise("no adapter is bound")
    end

    def bound?
      !@adapter.nil?
    end

    def bind(adapter, vars = {})
      unbind if bound?
      @adapter = adapter
      @before_sql, @sql, @after_sql = @originals.map {|str| format(str, vars) }

      if before_sql
        adapter.exec(before_sql)
      end
      self
    end

    def prepare
      unless prepared?
        @signature = adapter.prepare(query_name, @sql, signature)
      end
      self
    end

    def prepared?
      @signature ? true : false
    end

    def exec(args = {})
      if args.kind_of?(Array)
        args = Hash[signature.zip(args)]
      end
      adapter.exec(sql(args))
    end

    def exec_prepared(args = [])
      if args.kind_of?(Hash)
        args = signature.map {|key| args[key] }
      end
      adapter.exec_prepared(query_name, args)
    end

    def deallocate
      if prepared?
        adapter.deallocate(query_name)
        @signature = nil
      end
      self
    end

    def unbind
      deallocate

      if after_sql
        adapter.exec(after_sql)
      end

      @before_sql, @sql, @after_sql = @originals
      @adapter = nil
      self
    end

    def query_name
      @query_name ||= "#{name}_query"
    end

    def sql(args = {})
      argh = {}

      args.each_pair do |key, value|
        argh[key] = adapter.escape_literal(value)
      end

      self.args.each_pair do |key, default|
        argh[key] ||= adapter.escape_literal(default)
      end

      @sql % argh
    end

    protected

    def format(str, vars = {})
      return str if str.nil?

      argh = {}

      vars.each_pair do |key, value|
        argh[key] = adapter.escape(value)
      end

      self.vars.each_pair do |key, value|
        argh[key] ||= adapter.escape(value)
      end

      args.each_key do |key|
        argh[key] = "%{#{key}}"
      end

      str % argh
    end
  end
end
