require 'yaml'
require 'optparse'
require 'logging'
require 'dbu/config'
require 'dbu/registry'
require 'dbu/version'

module Dbu
  LOG_LEVELS = %w{debug info warn error}

  module_function

  def project_dir
    File.expand_path("../..", __FILE__)
  end

  def prototype_dir
    File.expand_path("db/prototype", project_dir)
  end

  def default_log_level
    LOG_LEVELS.index('warn')
  end

  def setup(options = {})
    Logging.init LOG_LEVELS

    level = options.fetch(:level, default_log_level)
    pattern = options.fetch(:pattern, '[%d] %-5l %p %c %m\n')
    date_pattern = options.fetch(:date_pattern, "%H:%M:%S.%3N")

    min_level, max_level = 0, LOG_LEVELS.length
    level = min_level if level < min_level
    level = max_level if level > max_level

    layout = Logging.layouts.pattern(:pattern => pattern, :date_pattern => date_pattern)
    Logging.appenders.stderr(:layout => layout)

    logger = Logging.logger.root
    logger.level = level
    logger.add_appenders "stderr"
  end

  def options(overrides = {})
    options = {
      :environment => ENV['DBU_ENVIRONMENT']    || 'development',
      :config_file => ENV['DBU_DATABASE_FILE']  || 'config/database.yml',
      :level       => ENV['DBU_LOG_LEVEL']      || default_log_level
    }.merge(overrides)
  end

  def init_config(options = {})
    config_file = options[:config_file]
    environment = options[:environment]
    Config.new(YAML.load_file(config_file).fetch(environment))
  end

  def version
    "dbu %s" % [Dbu::VERSION]
  end
end
