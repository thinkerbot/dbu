require 'dbu/adapter'

module Dbu
  module Adapters
    class Mysql < Adapter
      def command_args(options = {})
        command = ["mysql", "-h", config.host, "-P", config.port, "-u", config.username, config.database]

        if options[:stream]
          if options[:field_sep] != "\t"
            raise "mysql does not support setting a non-tab field sep"
          end
          command += ["--batch", "--skip-column-names"]
        end

        if options[:headers]
          command += ["--column-names"]
        end

        if options[:mode] == 'preview'
          command += ["-p"]
        end

        command
      end

      def command_env
        env = super
        env["MYSQL_PWD"] = config.password if config.password
        env
      end
    end
  end
end
