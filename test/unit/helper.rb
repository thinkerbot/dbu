require "bundler"
require "test/unit"
require "logging"

Bundler.setup

verbosity = 0
ARGV.map {|arg| arg =~ /^-(v+)$/; verbosity += $1.to_s.length }

case
when verbosity == 2
  ENV['TEST_LOG_LEVEL'] = "info"
when verbosity >= 3
  ENV['TEST_LOG_LEVEL'] = "debug"
end

module LoggingHelper
  def setup
    super
    if log_level = ENV['TEST_LOG_LEVEL']
      enable_stderr_log(log_level)
    end
  end

  def teardown
    disable_stderr_log
    disable_capture_log
    super
  end

  def logger_layout
    Logging.layouts.pattern(:pattern => '[%d] %-5l %c %m\n', :date_pattern => "%H:%M:%S.%3N")
  end

  def enable_stderr_log(level = 'debug')
    # for clean output in console
    $stderr.puts

    logger = Logging.logger.root
    logger.level = level

    Logging.appenders.stderr(:layout => logger_layout)
    logger.add_appenders 'stderr'
  end

  def disable_stderr_log
    Logging.logger.root.remove_appenders 'stderr'
  end

  def enable_capture_log(level = 'debug')
    logger = Logging.logger.root
    logger.level = level

    @capture_log_appender = Logging::Appenders.string_io("capture", :layout => logger_layout)
    logger.add_appenders @capture_log_appender
  end

  def disable_capture_log
    if @capture_log_appender
      Logging.logger.root.remove_appenders @capture_log_appender
    end
  end

  def capture_log
    current = @capture_log_appender
    begin
      enable_capture_log
      yield
      @capture_log_appender.sio.string
    ensure
      disable_capture_log
      @capture_log_appender = current
    end
  end

  def string_io_logger
    Logging.logger(StringIO.new)
  end
end

module AdapterHelper
  include LoggingHelper

  def config_file
    File.expand_path('../../../config/database.yml', __FILE__)
  end

  def environment
    'test'
  end

  def config
    @config ||= Dbu::Config.load_from(config_file, environment)
  end

  def adapter
    @adapter ||= config.adapter
  end
end
