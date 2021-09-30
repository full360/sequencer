#!/usr/bin/env bash

if [ -n "$AWS_REGION" ]
then
  aws s3 cp $SEQUENCER_YAML_S3_PATH /sequencer/file.yml --region $AWS_REGION
else
  aws s3 cp $SEQUENCER_YAML_S3_PATH /sequencer/file.yml
fi

sequencer /sequencer/file.yml
