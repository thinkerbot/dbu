module Dbu
  class Builder
    attr_reader :name
    attr_reader :registry

    def initialize(name, registry)
      @name = name
      @registry = registry
    end

    def desc(str)
      registry.summaries[name] = str
    end

    def descr(str)
      registry.summaries[name] = str
    end

    def query(*args)
      sql = args.pop
      signature = args

      key = registry.lookup_key(name, signature)
      registry.logger.info "register #{key}"
      registry.queries[key] = [key, sql, args]
    end
  end

  class Registry
    attr_reader :path
    attr_reader :queries
    attr_reader :summaries
    attr_reader :logger

    def initialize(path)
      @path = path
      @queries = {}
      @summaries = {}
      @logger = Logging.logger[self]
    end

    def query_file(name)
      File.extname(name) == '.rb' ? name : "#{name}.rb"
    end

    def find_query(name)
      path.each do |path_prefix|
        query_file = File.join(path_prefix, query_file(name))
        logger.debug "check #{query_file}"
        return query_file if File.exists?(query_file)
      end
      nil
    end

    def lookup_key(name, args)
      "#{name}_#{args.length}"
    end

    def lookup(name, args)
      logger.debug "lookup #{name} #{args.inspect}"
      key = lookup_key(name, args)

      unless queries.has_key?(key)
        if query_file = find_query(name)
          query_text = File.read(query_file)
          logger.debug "build #{query_file}"
          Builder.new(name, self).instance_eval(query_text)
        end
      end

      queries[key] or raise("no such query #{name}(#{args.length})")
    end
  end
end
