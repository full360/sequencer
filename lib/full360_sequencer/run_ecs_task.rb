require "aws-sdk"
require "logger"

module Full360
  module Sequencer
    class RunECSTask < RunTaskBase
      attr_accessor :task_name
      attr_accessor :params
      attr_accessor :ecs_client
      attr_accessor :logger

      attr_reader :cluster

      def initialize(task_name, params, ecs_client = nil, logger = nil)
        @logger     = logger ? logger : Logger.new(STDOUT)
        @ecs_client = ecs_client ||= Aws::ECS::Client.new
        @task_name  = task_name
        @params     = params[:parameters]
        @cluster    = self.params[:cluster]
      end

      def run_task
        logger.info("starting ECS task #{@task_name}")

        resp = ecs_run_task
        @task_arn = resp.tasks.first.task_arn

        logger.info("#{task_name} task created #{@task_arn} on cluster #{cluster}")
      end

      def ecs_run_task
        logger.debug("running ECS task #{@task_name}...")
        @start_time = Time.new.utc

        resp = @ecs_client.run_task(@params)
        resp
      rescue => e
        logger.error("SEQUENCER_ERROR: response from ECS: #{resp}")
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
        retries ||= 0

        resp = ecs_describe_tasks
        status = last_task_status(resp)

        logger.info("#{@task_name} : #{@task_arn} current status: #{status}")

        response = false

        if status == "STOPPED"
          logger.info("#{@task_name} completed in #{Time.new - @start_time} seconds")
          # parse exit_code(s) and return completion
          @success = determine_success(resp)
          response = true
        end

        response
      rescue => e
        logger.warn(e.message)
        logger.warn("task completion check failed, trying again ##{ retries }")

        sleep 10*retries

        retry if (retries += 1) < 3

        logger.error("SEQUENCER_ERROR: #{e.message}")
        e.backtrace.each { |r| @logger.error(r) }
      end

      # parses last status from aws API response
      def last_task_status(resp)
        resp.tasks[0].last_status
      end

      # success is determined by all containers having zero exit code
      def determine_success(resp)
        success = true

        resp.tasks.first.containers.each do |c|
          logger.info("#{task_name}: container #{c.name} #{c.container_arn} completed with exit_code #{c.exit_code}")

          # we had a problem!
          success = false if c.exit_code != 0
        end

        success
      end
    end
  end
end
