# Prepare the codebase

Copy `aws_deployment.env.template` to a file  `aws_deployment.env` and enter your AWS credentials. Those credentials will be made available as part of the build automatically.

# Deploying this application

At first get the [Codeship Jet CLI](https://codeship.com/documentation/docker/cli/) and [install Docker on your local system](https://docs.docker.com/engine/installation/).

Running `jet steps` in the repository will run Rubocop on the CloudFor
 teamplate and compile it from ruby to JSON.

As a next step you need to deploy the CloudFormation stack. You can do this by running `jet steps --tag cloudformation`. After that wait for the CloudFormation UI to report that the stack was deployed successfully.

After the stack deployment you can take the ElasticBeanstalk Application, Environment and S3 Bucket name to update the deployment scripts. Go into the `codeship-steps.yml` file and update the corresponding values in the ElasticBeanstalk deployment.

After that run `jet steps --ci-commit-id="HEAD" --ci-build-id="12345" --tag elasticbeanstalk` to deploy the codebase to ElasticBeanstalk. We have to provide a --ci-commit-id and --ci-build-id as they are used by the deployment script. Of course the same works as well if you run it through the [Codeship Docker infrastructure](http://pages.codeship.com/docker).

Now the application should be deployed and accessible.
