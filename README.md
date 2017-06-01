Sequencer is a tool that supports the synchronous execution of docker containers running in Amazon ECS for the purpose of batch processing.

While there are many solutions for container orchestration, most of them are focused on managing and scaling long running microservices, where a group of containers need to kept alive and able to talk to each other. This model is quite different from the execution of a nightly ETL batch where a container performs each of the following actions:

* collect the data from source system
* transform the data into the data lake
* ingest the data into the database
* transform the data inside the database with SQL
* export data to downstream consumers such as third parties or BI tools

AWS Batch service could do the above but it is currently only available in a single region.

At one end of the spectrum your other options fall into the realm of shell scripts.. while the other end brings you powerful (and cool!) DAG based tools such as Nomad and Airflow. 

We consider the DAG based tools to be way overkill for a simple batch of synchronous jobs, so we opted to expand on the idea of a shell script.

Putting a shell script into a container is easy enough, but it requires that you build and deploy a new container every time you make a change.

Sequencer allows you to define a list of ECS tasks in a yaml file, the location of which is passed into the container at run time. This yaml file can sit in a Git or S3 repository. Sequencer will synchronously run each container, passing in your override parameters as specified.


