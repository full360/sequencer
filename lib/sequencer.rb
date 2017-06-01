#!/usr/bin/ruby
require 'aws-sdk'
require 'yaml'
require 'logger'

module Full360
  module Sequencer
    class Runner
      attr_accessor :sleep_between_checks
      
      def initialize(yaml_path, logger = nil)
        @logger = logger ? logger : Logger.new(STDOUT)
        @config = YAML.load_file(yaml_path)
        
        # default 5 seconds between has_completed? checks
        @sleep_between_checks = 5
      end
      
      def run_task_class(task_type_string)
        case task_type_string
        when 'ecs_task' then Full360::Sequencer::RunECSTask
        else nil
        end
      end

      def run
        @config.each do |params|
          this_task_name = params.keys.first
          this_task = run_task_class(params[this_task_name]['type']).new(
            this_task_name,
            params[this_task_name]
          )
          this_task.start_task
          until this_task.completed?
            sleep @sleep_between_checks
          end
        end
      end
    end
    
    class RunTaskBase
      def start_task; end
      def completed?; end
      def kill_task; end
    end

    class RunECSTask < RunTaskBase
      def initialize(task_name, params, logger = nil)
        @logger = logger ? logger : Logger.new(STDOUT)
        @task_name = task_name
        @params = params['parameters']
        
        # replaces string keys with symbol keys
        # required by AWS SDK
        @params = @params.inject({}){ |memo,(k,v)| memo[k.to_sym] = v; memo }

        @cluster = @params[:cluster]
      end

      def start_task
        @logger.info("starting ECS task #{@task_name}")
        @ecs_client = ::Aws::ECS::Client.new
        resp = @ecs_client.run_task(@params)
        @task_arn = resp.tasks[0].task_arn

        @logger.info("#{@task_name} task created #{@task_arn} on cluster #{@cluster}")
      end

      def completed?
        resp_task = @ecs_client.describe_tasks(
          {
            cluster: @cluster,
            tasks: [@task_arn] # required
          }
        )
        status = resp_task.tasks[0].last_status
        @logger.info("#{@task_name} : #{@task_arn} current status: #{status}")
        return true if status == 'STOPPED'
        false
      end
    end
  end
end
