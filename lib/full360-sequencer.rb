#!/usr/bin/ruby
require 'aws-sdk'
require 'yaml'
require 'logger'
require 'pp'

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
        when 'ecs_task' then Full360::Sequencer::RunECSTask
        else nil
        end
      end

      def run
        @config.each do |params|
          this_task_name = task_name(params)
          this_task = run_task_class(params[this_task_name]['type']).new(
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
        @logger.error('SEQUENCER_ERROR')
        @logger.error(e.message)
        e.backtrace.each { |r| @logger.error(r) }
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
    
    class RunTaskBase
      attr_reader :success
      attr_reader :exit_code
      
      def run_task; end
      def completed?; end
      def kill_task; end #will be used for timeout
    end

    class RunECSTask < RunTaskBase
      def initialize(task_name, params, logger = nil)
        @logger = logger ? logger : Logger.new(STDOUT)
        @task_name = task_name
        @params = params['parameters']
        @params = keys_to_symbol(@params)
        @cluster = @params[:cluster]
      end
      
      def keys_to_symbol(params)
        # replaces string keys with symbol keys
        # required by AWS SDK
        if params.is_a?(Hash)
          params.inject({}){ |memo,(k,v)| memo[k.to_sym] = v; memo }
        else
          nil
        end
      end

      def run_task
        @logger.info("starting ECS task #{@task_name}")
        resp = ecs_run_task
        @task_arn = resp.tasks[0].task_arn
        @logger.info("#{@task_name} task created #{@task_arn} on cluster #{@cluster}")
      end
      
      def ecs_run_task
        @logger.debug("creating AWS client for ECS task #{@task_name}...")
        @ecs_client = ::Aws::ECS::Client.new
        @logger.debug("running ECS task #{@task_name}...")
        @start_time = Time.new
        resp = @ecs_client.run_task(@params)
        return resp
      rescue => e
        @logger.error('SEQUENCER_ERROR')
        @logger.error("error creating ECS task...")
        @logger.error("response from ECS: #{resp}")
        raise e
      end

      def ecs_describe_tasks
        @ecs_client.describe_tasks(
          {
            cluster: @cluster,
            tasks: [@task_arn] # required
          }
        )
      end
      
      def completed?
        resp = ecs_describe_tasks
        status = last_task_status(resp)
        @logger.info("#{@task_name} : #{@task_arn} current status: #{status}")
        if status == 'STOPPED'
          @logger.info("#{@task_name} completed in #{Time.new - @start_time} seconds")
          # parse exit_code(s) and return completion
          @success = determine_success(resp)
          return true 
        end
        false
      rescue => e
        @logger.error('SEQUENCER_ERROR')
        @logger.error(e.message)
        e.backtrace.each { |r| @logger.error(r) }
      end
      
      # parses last status from aws API response
      def last_task_status(resp)
        resp.tasks[0].last_status
      end
      
      # success is determined by all containers having zero exit code
      def determine_success(resp)
        success = true
        resp.tasks[0].containers.each do |c|
          @logger.info("#{@task_name} : container #{c.name} #{c.container_arn} completed with exit_code #{c.exit_code}")
          if c.exit_code != 0
            # we had a problem!
            success = false
          end
        end
        success
      end
    end
  end
end
