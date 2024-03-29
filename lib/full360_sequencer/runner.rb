require "yaml"
require "logger"
require "full360_sequencer/run_ecs_task"

module Full360
  module Sequencer
    class Runner
      attr_accessor :sleep_between_checks
      attr_accessor :logger

      attr_reader :config

      # Initializes the class
      # @params sleep_between_checks [Int]
      # @params logger [Logger]
      # @return [Full360::Sequencer::Runner]
      def initialize(sleep_between_checks, logger = nil)
        @sleep_between_checks = sleep_between_checks
        @logger               = logger ||= Logger.new(STDOUT)
      end

      def config_from_file(yaml_path)
        @config = parse_config_file(yaml_path)
      end

      def run_task_class(task_type_string)
        case task_type_string
        when "ecs_task"
          Full360::Sequencer::RunECSTask
        else
          nil
        end
      end

      def run
        config.each do |params|
          this_task_name = task_name(params)

          this_task = run_task_class(params[this_task_name][:type]).new(
            this_task_name,
            params[this_task_name]
          )

          this_task.run_task

          until this_task.completed?
            sleep sleep_between_checks
          end

          raise "task failed error" unless this_task.success
        end
      rescue => e
        logger.error("SEQUENCER_ERROR: #{e.message}")

        e.backtrace.each { |r| logger.error(r) }
        raise e
      end

      def task_name(params)
        params.keys.first
      end

      def config_valid?(config)
        return false unless config.is_a? Array
        true
      end

      private

      # parse_config_file reads and parses the configuration file and returns
      # an array of hashes with symbolize keys ready to consume.
      # @params yaml_path [String]
      # @return [Array]
      def parse_config_file(yaml_path)
        YAML.safe_load(yaml_path, symbolize_names: true)
      end
    end
  end
end
