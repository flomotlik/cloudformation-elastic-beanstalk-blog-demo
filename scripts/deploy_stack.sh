#!/bin/bash

set -e

mkdir -p tmp

OUTPUT_FILE_PATH='tmp/outputtemplate.json'

# Compile Ruby template into JSON
bundle exec cfndsl infrastructure.template.rb > $OUTPUT_FILE_PATH

STACK_NAME="elasticbeanstalkstack"

# Set default Cloudformation command to create and set to update if stack already exists
CF_COMMAND="create"

if aws cloudformation describe-stacks --stack-name $STACK_NAME --profile sandbox &> /dev/null
then
  CF_COMMAND="update"
fi

aws cloudformation $CF_COMMAND-stack --stack-name $STACK_NAME --template-body file://`pwd`/$OUTPUT_FILE_PATH --capabilities CAPABILITY_IAM --profile sandbox
