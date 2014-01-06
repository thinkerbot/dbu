require 'dbu/registry'
require 'dbu/adapters'
require 'dbu/previewers'

module Dbu
  class Config
    class << self
      def load_from(config_file, environment = 'development')
        require 'yaml'
        new(YAML.load_file(config_file).fetch(environment))
      end
    end

    attr_reader :options

    def initialize(options)
      @options = options
    end

    def [](key)
      options[key]
    end

    def adapter_name
      options['dbu']
    end

    def adapter
      @adapter ||= Adapters.lookup(adapter_name).new(self)
    end

    def previewer
      @previewer ||= Previewers.lookup(adapter_name)
    end

    def host
      options['host']
    end

    def database
      options['database']
    end

    def port
      options['port']
    end

    def username
      options['username']
    end

    def password
      options['password']
    end

    def path
      path = options['dbu_path'] || File.expand_path('db/dbu')
      path.to_s.split(':') + [File.expand_path("../../../db/dbu/#{adapter_name}", __FILE__)]
    end

    def registry
      Registry.new(path)
    end
  end
end
