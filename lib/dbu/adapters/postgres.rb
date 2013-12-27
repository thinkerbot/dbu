require 'dbu/adapter'

module Dbu
  module Adapters
    class Postgres < Adapter
      def command_args(options = {})
        command = ["psql", "-h", config.host, "-p", config.port, "-U", config.username, "-d", config.database]

        if options[:stream]
          command += ["--no-align", "--field-separator", options[:field_sep], "--tuples-only", "--quiet"]
        end

        if options[:headers]
          command -= ["--tuples-only"]
          command += ["--pset=footer=off"]
        end

        command
      end

      def command_env
        env = super
        env["PGPASSWORD"] = config.password if config.password
        env
      end
    end
  end
end
