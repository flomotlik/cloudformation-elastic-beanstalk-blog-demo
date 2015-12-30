#!/bin/bash

set -e

mkdir -p tmp

STACK_NAME="elasticbeanstalkstack"

# Set default Cloudformation command to create and set to update if stack already exists
CF_COMMAND="create"

if aws cloudformation describe-stacks --stack-name $STACK_NAME &> /dev/null
then
  CF_COMMAND="update"
fi

aws cloudformation $CF_COMMAND-stack --stack-name $STACK_NAME --template-body file:///deploy/tmp/outputtemplate.json --capabilities CAPABILITY_IAM
