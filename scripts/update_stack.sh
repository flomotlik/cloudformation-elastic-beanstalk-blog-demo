#!/bin/bash

aws cloudformation update-stack --stack-name elasticbeanstalkstack --template-body file://`pwd`/Infrastructure.template.json --capabilities CAPABILITY_IAM --profile sandbox
