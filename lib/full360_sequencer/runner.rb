require "yaml"
require "logger"

module Full360
  module Sequencer
    class Runner
      attr_accessor :sleep_between_checks
      attr_accessor :config

      def initialize(logger = nil)
        @logger = logger ? logger : Logger.new(STDOUT)

        # default 5 seconds between completed? checks
        @sleep_between_checks = 5
      end

      def config_from_file(yaml_path)
        @config = parse_config_file(yaml_path)
      end

      def run_task_class(task_type_string)
        case task_type_string
        when "ecs_task" then Full360::Sequencer::RunECSTask
        else nil
        end
      end

      def run
        @config.each do |params|
          this_task_name = task_name(params)
          this_task = run_task_class(params[this_task_name]["type"]).new(
            this_task_name,
            params[this_task_name]
          )
          this_task.run_task
          until this_task.completed?
            sleep @sleep_between_checks
          end
          raise "task failed error" unless this_task.success
        end
      rescue => e
        @logger.error("SEQUENCER_ERROR")
        @logger.error(e.message)
        e.backtrace.each { |r| @logger.error(r) }
        raise e
      end

      def task_name(params)
        params.keys.first
      end

      def parse_config_file(yaml_path)
        YAML.load_file(yaml_path)
      end

      def config_valid?(config)
        return false unless config.is_a? Array
        true
      end
    end
  end
end
