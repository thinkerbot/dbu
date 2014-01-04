require 'dbu/query_builder'

module Dbu
  class Registry
    attr_reader :path
    attr_reader :queries
    attr_reader :logger

    def initialize(path)
      @path = path
      @queries = {}
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
          logger.debug "build #{query_file}"
          register QueryBuilder.build_from(query_file)
        end
      end
    end

    def lookup(name)
      logger.debug "lookup #{name}"

      unless queries.has_key?(name)
        if query_file = find_query_file(name)
          logger.debug "build #{query_file}"
          register QueryBuilder.build_from(query_file)
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
