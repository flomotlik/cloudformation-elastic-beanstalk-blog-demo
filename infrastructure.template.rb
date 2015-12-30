require 'cfndsl'

CloudFormation do
  Description 'ElasticBeanstalk application with export to Cloudwatch Logs'

  ElasticBeanstalk_Application('DemoDockerApplication') do
    Property('Description', 'AWS Elastic Beanstalk Application')
  end

  Logs_LogGroup('ElasticBeanstalkMainLogGroup')

  ElasticBeanstalk_Environment('DemoEnvironment') do
    DependsOn %w(DemoDockerApplication ElasticBeanstalkMainLogGroup)
    ApplicationName Ref('DemoDockerApplication')
    Description 'AWS Elastic Beanstalk Environment'
    SolutionStackName '64bit Amazon Linux 2015.09 v2.0.4 running Docker 1.7.1'
    OptionSettings [
      {
        Namespace: 'aws:autoscaling:launchconfiguration',
        OptionName: 'IamInstanceProfile',
        Value: Ref('ElasticBeanstalkInstanceProfile')
      },
      {
        Namespace: 'aws:elasticbeanstalk:customoption',
        OptionName: 'EBLogGroup',
        Value: Ref('ElasticBeanstalkMainLogGroup')
      }]
  end

  Output('URL') do
    Description 'The URL of the Elastic Beanstalk environment'
    Value FnJoin('', ['http://', FnGetAtt('DemoEnvironment', 'EndpointURL')])
  end

  S3_Bucket('ElasticBeanstalkDeploymentBucket')

  Output('EBDeploymentBucketName') do
    Value Ref('ElasticBeanstalkDeploymentBucket')
  end

  IAM_Role('ElasticBeanstalkLoggingRole') do
    AssumeRolePolicyDocument(
      Version: '2012-10-17',
      Statement: [{
        Effect: 'Allow',
        Principal: {
          Service: ['ec2.amazonaws.com']
        },
        Action: ['sts:AssumeRole']
      }]
    )
    Path '/'
    Policies [{
      PolicyName: 'ElasticBeanstalkLogging',
      PolicyDocument: ({
        Version: '2012-10-17',
        "Statement": [
          {
            "Effect": 'Allow',
            "Action": [
              'logs:CreateLogGroup',
              'logs:CreateLogStream',
              'logs:GetLogEvents',
              'logs:PutLogEvents',
              'logs:DescribeLogGroups',
              'logs:DescribeLogStreams',
              'logs:PutRetentionPolicy'
            ],
            "Resource": [
              'arn:aws:logs:us-west-2:*:*'
            ]
          }
        ]
      })
    }]
  end

  IAM_InstanceProfile('ElasticBeanstalkInstanceProfile') do
    Path '/'
    Roles [Ref('ElasticBeanstalkLoggingRole')]
  end
end
