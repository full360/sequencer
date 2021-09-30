# Full 360 Sequencer

Sequencer is a tool that supports the synchronous execution of docker containers
running in Amazon ECS for the purpose of batch processing.

While there are many solutions for container orchestration, most of them are
focused on managing and scaling long running microservices, where a group of
containers need to kept alive and able to talk to each other. This model is
quite different from the execution of a nightly ETL batch where a container
performs a series of actions such as:

* collect the data from source system
* transform the data into the data lake
* ingest the data into the database
* transform the data inside the database with SQL
* export data to downstream consumers such as third parties or BI tools

AWS Batch service could do the above but it is currently only available in a
single region.

At one end of the spectrum your other options fall into the realm of shell
scripts.. while the other end brings you powerful (and cool!) DAG based tools
such as Nomad and Airflow.

We consider the DAG based tools to be way overkill for a simple batch of
synchronous jobs, so we opted to expand on the idea of a shell script.

Putting a shell script into a container is easy enough, but it requires that you
build and deploy a new container every time you make a change.

Sequencer allows you to define a list of ECS tasks in a yaml file, the location
of which is passed into the container at run time. This yaml file can sit in an
S3 repository (git support forthcoming). Sequencer will synchronously run each
task, passing in your override parameters as specified.

## Installing Sequencer

Sequencer is installed as a ruby gem:

    gem install full360-sequencer

Once installed... you can run the sequencer command from anywhere on your
system. Simply pass the path to your YAML file as a parameter. Note that you
will need to export some environment variables in order to use the AWS API.

    $ export AWS_ACCESS_KEY_ID=aaaaaaaaayourkey
    $ export AWS_SECRET_ACCESS_KEY=bbbbbbbbbbbbbbbbbbbbbbbbbbbbyoursecret
    $ export AWS_REGION=us-west-2
    $ sequencer mybatch.yml

Sequencer will utilize AWS instance or container roles if appropriate, though
you will have to provide `AWS_REGION` if you are not in us-east-1.

While using the command line sequencer is just fine, we suggest that you use the
full360/sequencer container available on Dockerhub.

## YAML File Specification

Sequencer requires a yaml file with the following structure:

```yaml
- first_task:
    type: ecs_task
    parameters:
      cluster: yourcluster
      task_definition: test-task-def:1
      count: 1
- first_task:
    type: ecs_task
    parameters:
      cluster: yourcluster2
      task_definition: test-task-def:2
      count: 1
```

The top level structure is an array of tasks to be executed in the order shown.
Each task can be provided a name. Below each task you must specify the task
`type`. At this time, only ecs_task is supported as a task type.

The `parameters` element correlates to the request provided to the ECS run_task
API call. All of the elements are supported as long as you provide a YAML
structure. Refer to the API [reference][ref] for more details.

## Releasing

Releasing a new version of the Gem requires a few steps:
- Update the `CHANGELOG.md` file
  - Add a new section for the [UNRELEASED] code
  - Check that all changes are reflected for the current release version
- Update the `version.rb` file
- Do a bundle install to ensure we are locking the latest version
- Commit all the changes
  - Example: `git commit -m "Bump gem to version 1.0.0"`
- Create a Git tag that matches the version number in `version.rb`
  - Example: `git tag -m "Version 1.0.0" v1.0.0`

## Running the Sequencer from Docker

Pass the following environment variables to the container at runtime:

* `SEQUENCER_YAML_S3_PATH` - s3:// path to the yaml configuration file.
* `AWS_REGION` - AWS region in which you are running the container.

[ref]: http://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_RunTask.html
