require 'cfndsl'

CloudFormation {
  Description 'AWS ElasticBeanstalk application with Load Balancing in public subnet and Servers in private subnet'
  ElasticBeanstalk_Application('DockerApplication') {
    Property('Description', 'AWS Elastic Beanstalk Application')
    ApplicationVersions []
  }

  ElasticBeanstalk_Environment('SampleEnvironment') {
    DependsOn ['DockerApplication']
    ApplicationName Ref('DockerApplication')
    Description 'AWS Elastic Beanstalk Environment'
    SolutionStackName '64bit Amazon Linux 2015.09 v2.0.4 running Docker 1.7.1'
    OptionSettings [
      {
        Namespace: 'aws:autoscaling:launchconfiguration',
        OptionName: 'IamInstanceProfile',
        Value: Ref('ElasticBeanstalkInstanceProfile')
      }
    ]
  }

  S3_Bucket('ElasticBeanstalkDeploymentBucket')

  IAM_Role('RootRole') {
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
        Statement: [{
          Effect: 'Allow',
          Action: '*',
          Resource: '*'
        }]
      })
      }
    ]
  }

  IAM_InstanceProfile('ElasticBeanstalkInstanceProfile') {
    Path '/'
    Roles [Ref('RootRole')]
  }

  Output('URL') {
    Description 'The URL of the Elastic Beanstalk environment'
    Value FnJoin("", ['http://', FnGetAtt('SampleEnvironment', 'EndpointURL')])
  }

  Output('EBDeploymentBucketName') {
    Value Ref('ElasticBeanstalkDeploymentBucket')
  }
}
