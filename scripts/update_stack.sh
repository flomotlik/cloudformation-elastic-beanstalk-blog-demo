#!/bin/bash

set -e

mkdir -p tmp

OUTPUT_FILE_PATH='tmp/outputtemplate.json'

bundle exec cfndsl infrastructure.template.rb > $OUTPUT_FILE_PATH

aws cloudformation update-stack --stack-name elasticbeanstalkstack --template-body file://`pwd`/$OUTPUT_FILE_PATH --capabilities CAPABILITY_IAM --profile sandbox
