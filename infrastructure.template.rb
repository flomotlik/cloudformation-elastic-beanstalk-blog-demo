require 'cfndsl'

CloudFormation {
  Description 'AWS ElasticBeanstalk application with Load Balancing in public subnet and Servers in private subnet'

  ElasticBeanstalk_Application('DemoDockerApplication') {
    Property('Description', 'AWS Elastic Beanstalk Application')
  }

  Logs_LogGroup('ElasticBeanstalkMainLogGroup')

  ElasticBeanstalk_Environment('DemoEnvironment') {
    DependsOn ['DemoDockerApplication', 'ElasticBeanstalkMainLogGroup']
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
      Namespace: "aws:elasticbeanstalk:customoption",
      OptionName: "EBLogGroup",
      Value: Ref('ElasticBeanstalkMainLogGroup')
    }]
  }

  Output('URL') {
    Description 'The URL of the Elastic Beanstalk environment'
    Value FnJoin("", ['http://', FnGetAtt('DemoEnvironment', 'EndpointURL')])
  }

  S3_Bucket('ElasticBeanstalkDeploymentBucket')

  Output('EBDeploymentBucketName') {
    Value Ref('ElasticBeanstalkDeploymentBucket')
  }

  IAM_Role('ElasticBeanstalkLoggingRole') {
    AssumeRolePolicyDocument ({
      Version: '2012-10-17',
      Statement: [{
        Effect: 'Allow',
        Principal: {
          Service: ['ec2.amazonaws.com']
        },
        Action: ['sts:AssumeRole']
      }]
    })
    Path '/'
    Policies [ {
      PolicyName: 'ElasticBeanstalkLogging',
      PolicyDocument: ({
        Version: '2012-10-17',
        "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:GetLogEvents",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutRetentionPolicy"
      ],
      "Resource": [
        "arn:aws:logs:us-west-2:*:*"
      ]
    }
  ]
      })
      }
    ]
  }

  IAM_InstanceProfile('ElasticBeanstalkInstanceProfile') {
    Path '/'
    Roles [Ref('ElasticBeanstalkLoggingRole')]
  }

}
