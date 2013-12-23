require 'yaml'
require 'optparse'
require 'dbu/version'

module Dbu
  module_function

  def options(overrides = {})
    options = {
      :environment => ENV['DBU_ENVIRONMENT'] || 'development',
      :config_file => ENV['DBU_DATABASE_FILE'] || 'config/database.yml',
    }.merge(overrides)
  end

  def load_db_config(options = {})
    config_file = options[:config_file]
    environment = options[:environment]
    YAML.load_file(config_file).fetch(environment)
  end

  def version
    "dbu %s" % [Dbu::VERSION]
  end
end
