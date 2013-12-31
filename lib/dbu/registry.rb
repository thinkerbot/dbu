require 'dbu/queries/interpolated'
require 'dbu/queries/prepared'

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

    def query(*args)
      args.unshift(args.pop)
      query = Queries::Interpolated.new(name, *args)
      registry.register(query)
    end

    def prepare(*args)
      args.unshift(args.pop)
      query = Queries::Prepared.new(name, *args)
      registry.register(query)
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

    def find_query_file(name)
      path.each do |path_prefix|
        query_file = File.join(path_prefix, query_file(name))
        logger.debug "check #{query_file}"
        return query_file if File.exists?(query_file)
      end
      nil
    end

    def populate
      path.each do |path_prefix|
        query_files = Dir.glob("#{path_prefix}/*.rb")
        query_files.each do |query_file|
          name = File.basename(query_file, ".rb")
          query_text = File.read(query_file)
          logger.debug "build #{query_file}"
          Builder.new(name, self).instance_eval(query_text)
        end
      end
    end

    def lookup(name)
      logger.debug "lookup #{name}"

      unless queries.has_key?(name)
        if query_file = find_query_file(name)
          query_text = File.read(query_file)
          logger.debug "build #{query_file}"
          Builder.new(name, self).instance_eval(query_text)
        end
      end

      queries[name] or raise("no such query #{name.inspect}")
    end

    def register(query)
      logger.info "register #{query.name}"
      queries[query.name] = query
    end
  end
end
