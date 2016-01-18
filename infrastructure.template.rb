require 'cfndsl'

CloudFormation do
  Description 'ElasticBeanstalk application with export to Cloudwatch Logs'

  ElasticBeanstalk_Application('DemoDockerApplication') do
    Property('Description', 'AWS Elastic Beanstalk Application')
  end

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

  Logs_LogGroup('ElasticBeanstalkMainLogGroup')

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
              'logs:CreateLogStream',
              'logs:GetLogEvents',
              'logs:PutLogEvents',
              'logs:DescribeLogGroups',
              'logs:DescribeLogStreams',
              'logs:PutRetentionPolicy'
            ],
            "Resource": [
              'arn:aws:logs:us-east-1:*:*'
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

  Logs_MetricFilter('HelloWordMetric') do
    LogGroupName Ref('ElasticBeanstalkMainLogGroup')
    FilterPattern 'Hello World'
    MetricTransformations [
      {
        "MetricValue": 1,
        "MetricName": 'HelloWorldOccurences',
        "MetricNamespace":
          FnJoin('/', ['ElasticBeanstalk', Ref('DemoEnvironment')])
      }
    ]
  end

  CloudWatch_Alarm('HelloWorld') do
    AlarmDescription 'Alert if HelloWorld is sent'
    MetricName 'HelloWorldOccurences'
    Namespace FnJoin('/', ['ElasticBeanstalk', Ref('DemoEnvironment')])
    Statistic 'Sum'
    Period '60'
    EvaluationPeriods '1'
    Threshold '1'
    ComparisonOperator 'GreaterThanThreshold'
    AlarmActions [Ref('AlarmNotifications')]
  end

  SNS_Topic('AlarmNotifications') do
    DisplayName 'Email Alarm Notification'
    Subscription [
      {
        "Endpoint": 'flomotlik@gmail.com',
        "Protocol": 'email'
      }
    ]
  end
end
