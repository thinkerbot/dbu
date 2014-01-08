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

  def default_log_format
    '[%d] %-5l %p %c %m\n'
  end

  def default_log_datetime_format
    "%H:%M:%S.%3N"
  end

  def setup(options = {})
    Logging.init LOG_LEVELS

    level = options[:log_level] || default_log_level
    format = options[:log_format] || default_log_format
    datetime_format = options[:log_datetime_format]|| default_log_datetime_format

    min_level, max_level = 0, LOG_LEVELS.length
    level = min_level if level < min_level
    level = max_level if level > max_level

    layout = Logging.layouts.pattern(:pattern => format, :date_pattern => datetime_format)
    Logging.appenders.stderr(:layout => layout)

    logger = Logging.logger.root
    logger.level = level
    logger.add_appenders "stderr"
  end

  def options(overrides = {})
    options = {
      :environment => ENV['DBU_ENVIRONMENT']    || 'development',
      :config_file => ENV['DBU_DATABASE_FILE']  || 'config/database.yml',
      :log_level   => ENV['DBU_LOG_LEVEL']      || default_log_level,
      :log_format  => ENV['DBU_LOG_FORMAT']     || default_log_format,
      :log_datetime_format => ENV['DBU_LOG_DATETIME_FORMAT'] || default_log_datetime_format,
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
