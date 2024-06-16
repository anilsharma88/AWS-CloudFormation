# A CloudFormation template is composed of multiple sections 
- Format Version
- Description
- Metadata
- Parameters
- Mappings
- Conditions
- Rule
- Metadata
- Transform
- Resources
- Outputs
    - cnf helper script 
# Format Version
```
AWSTemplateFormatVersion: 2010-09-09
```
# Description
```
Description: >-
  Network stack template for
  AWS CloudFormation Step by Step: Intermediate to Advanced course.
```
# [Parameter](https://www.obstkel.com/aws-cloudformation-parameters) In CloudFormation Template.
- The way to  provide inputs to your AWS CloudFormation Templates
- reuse
## Parameter Properties
- **AllowedPattern**	The approved format for the string type specified as a regular expression. For a database password for instance, this could be “^[a-zA-Z0-9]*$”
- **AllowedValues**	List containing the valid values for a parameter
- **ConstraintDescription**	Descriptive text on why a constraint was violated
- **Default**	Fallback value to use if a specific parameter is not specified
- **Description**	A description of what the parameter does limited to 4000 bytes
- **MaxLength**	Largest value allowed for a String type
- **MaxValue**	Largest value allowed for a Number type
- **MinLength**	Smallest value allowed for a String type
- **MinValue**	Smallest value allowed for a Number type
- **NoEcho**	Used to mask the parameter value displayed. As a best practice, try not to use this parameter
- **Type**	The datatype of the parameter. Can be String, Number, List, CommaDelimitedList, AWS-Specific Parameter types or SSM 

# Parameter Type
- **String**	Literal String.
- **Number**	Integer or floating-point number.
- **List**	An array of integers such as [“10″,”20”]
- **CommaDelimitedList**	An array of strings such as [“Name1”, “Name2”].
- **AWS-Specific Parameter Types**	These are used to validate existence of AWS resources and related objects.
- **SSM Parameter Types**	Parameters from the System Manager Parameter Store.
```
Parameters :
    DBName:
        Default: testDynamoDB
        Description : DynamoDB database name
        Type: String
        MinLength: 1
        MaxLength: 64
        AllowedPattern : [a-zA-Z][a-zA-Z0-9]*
        ConstraintDescription : Must start with a letter and contain only alphanumeric characters
    DBUser:
        NoEcho: true
        Description : Username for DynamoDB database
        Type: String
        MinLength: 1
        MaxLength: 16
        AllowedPattern : [a-zA-Z][a-zA-Z0-9]*
        ConstraintDescription : Must start with a letter and contain only alphanumeric characters
        DBPassword:
        NoEcho: true
        Description : Password for DynamoDB database
        Type: String
        MinLength: 8
        MaxLength: 41
        AllowedPattern : [a-zA-Z0-9]*
        ConstraintDescription : Alphanumeric characters only
    DbSubnetIpBlocks: 
        Description: "Comma-delimited list of three CIDR blocks"
        Type: CommaDelimitedList
        Default: "10.0.48.0/24, 10.0.112.0/24, 10.0.176.0/24"
    myKeyPair: 
        Description: Amazon EC2 Key Pair
        Type: "AWS::EC2::KeyPair::KeyName"
    mySubnetIDs: 
        Description: Subnet IDs
        Type: "List<AWS::EC2::Subnet::Id>"
    InstanceType: 
        Type: 'AWS::SSM::Parameter::Value<String>'
```
# Mapping in AWS 
- Mappings allow you to define a set of mapping in the CloudFormation template and !FindInMap is a function where you can use to retrieve the value that you defined in the mapping.
- !FindInMap [ MappName, 'FirstKey', 'SecondKey']
- 
```
Mappings:
  RegionEC2InstanceImageMap:
    us-east-2: 
      HVM64: "ami-0233c2d874b811deb"
    ap-southeast-1: 
      HVM64: "ami-0e5182fad1edfaa68"

Resources:
  TestInstance:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: !FindInMap
        - RegionEC2InstanceImageMap
        - !Ref 'AWS::Region'
        - HVM64
      InstanceType: t2.micro
```

# Conditions 
The following You can use the following intrinsic functions can be used to define conditions:

- Fn::And
- Fn::Equals
- Fn::ForEach
- Fn::If
- Fn::Not
- Fn::Or

```
conditions: 
  IsTesting: !Equals [ !Ref Environment, "testing" ]
  IsProductionOrAcceptance: !Or [ !Equals [ !Ref Environment, "production" ], !Equals [ !Ref Environment, "acceptance" ]]
  IsProduction: !Equals [ !Ref Environment, "production" ]

Resources:
  RdsClusterNew:
    Type: "AWS::RDS::DBCluster"
    Condition: IsTesting
    Properties:
      # ...
      DBClusterParameterGroupName: !If [ IsTesting, !Ref "RdsClusterParameterGroupWithPerformanceInsights", !Ref "RdsClusterParameterGroup" ]
```
Example 2
```
AWSTemplateFormatVersion: "2010-09-09"
Parameters:
   UseExistingResources:
   Type: String
   Default: false
    AllowedValues:
      - true
      - false

Conditions:
  DoUseExistingResources: !Equals [!Ref UseExistingResources, true]

EC2Instanace:
   Type: AWS::EC2::Instance
   Properties: 
      ......
      SubnetId:
         Fn::If:
            [DoUseExistingResources, !Ref ExistingSubnetID, !Ref NewCreatedSubnetId]

```
Exapmple 3
```
AWSTemplateFormatVersion: 2010-09-09

Parameters:

  Environment:
    Description: Defines environment type
    Type: String
    Default: dev
    AllowedValues:
      - dev
      - qa
      - beta
      - prod
    ConstraintDescription: Use valid environment [dev, qa, beta, prod]

Conditions:
  IsProd: !Equals [ !Ref Environment, prod ]
  IsLab: !Or [ !Equals [ dev, !Ref Environment ], !Equals [ qa, !Ref Environment ], !Equals [ beta, !Ref Environment ] ]
  IsLab2: !Not [ !Equals [ prod, !Ref Environment ] ]
  IsLab3: !Not [ !Condition IsProd ]

Resources:
  ProdBucket:
    Type: 'AWS::S3::Bucket'
    Condition: IsProd
  LabBucket:
    Type: 'AWS::S3::Bucket'
    Condition: IsLab
    #Condition: IsLab2
    #Condition: IsLab3

```

# Output 
```
Outputs:
  WebServerPublicDNS:
    Description: Public DNS name of the web server instance
    Value: !GetAtt WebServerInstance.PublicDnsName
```
# Rule
- **Rule** : Rules used to perform parameter validations based on the values of other parameters( cross parameter validation) 
- Supportes Function: Rule-spevfic Intrinsic Functions
    - Used to define a rule confition and assertions
    - function can be nested, but the result of a rule condition or assertion must be either true or false
    - Fn::And
    - Fn::Contain
    - Fn:EachMemberin
    - Fn::Equal
    - Fn::if
    - Fn::Not
    - Fn::Or
    - Fn::RefAll
    - Fn::ValueOf
    - Fn::ValueOfAll

- Enforce users to provide an ACM certificate ARN if they configure an SSL listener on an ALB
```
Rules: 
  IsSSLCertificate:
    RuleCondition: !Equals
       - !Ref UseSSL
         - yes
     Assertions:
       - Assert: !Not
           - !Equals
               - !Ref ALBSSSLCertificateARN
               - ''
        AssertDescription: 'ACM certificate value can not be empty if SSL is required''
```

```
AWSTemplateFormatVersion: 2010-09-09

Parameters:

  Environment:
    Description: Defines environment type
    Type: String
    Default: dev
    AllowedValues:
      - dev
      - qa
      - beta
      - prod
    ConstraintDescription: Use valid environment [dev, qa, beta, prod]

  NumberOfInstances:
    Description: Number of instances to launch
    Type: Number
    Default: 1
    MinValue: 1
    MaxValue: 5
    ConstraintDescription: Must be between 1 and 5

Rules:
  ProdEnvironmentRule:
    Assertions:
      - Assert: !Equals [ !Ref NumberOfInstances,  "5" ]
        AssertDescription: Prod environment must have 5 instances
    RuleCondition: !Equals [ !Ref Environment, prod ]

Resources:
  DemoBucket:
    Type: 'AWS::S3::Bucket'
    Properties:
      Tags:
        - Key: Environment
          Value: !Ref Environment
        - Key: NumberOfInstances
          Value: !Ref NumberOfInstances
```
# Metadata 
- AWS::CloudFormation::Interface
- This helps how to modify the ordering and presentation of parameters in the AWS CloudFormation console.
- metadata key uses two child keys,

    - ParameterGroups (you could group all EC2-related parameters in one group and all DB-related parameters in another group)
    - Each entry in ParameterGroups is defined as an object with a Label key and Parameters key

```
Metadata:
  'AWS::CloudFormation::Interface':
    ParameterGroups:
      - Label: 
          default: Authentication
        Parameters: 
          - ClientId
          - SigningKeyParameter
      - Label: 
          default: Application Domain
        Parameters:
          - Name
          - Domain
      - Label:
          default: System
        Parameters:
          - CloudFrontHostedZoneId
    ParameterLabels:
      SigningKeyParameter:
        default: Signing Key Parameter
      ClientId:
        default: Client ID
      CloudFrontHostedZoneId:
        default: CloudFront Hosted Zone ID
```
# CloudFormation Bootstrap UserData.
- Using user data you can install package in ec2 instance bootstrep
```
Resources:
  WebServerInstance:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: t2.micro
      ImageId: !Ref ImageId
      SecurityGroupIds: 
        - !Ref WebServerSecurityGroup
      SubnetId: !Ref SubnetId
      Tags:
        - Key: Name
          Value: !Sub '${AWS::StackName}-WebServer'
      UserData:
        Fn::Base64: |
          #!/bin/bash -xe
          yum update -y
          amazon-linux-extras install -y nginx1
          service nginx start
```
# Cloud Init Script 
- User data does't provide any signal if commands are executed sucessfully or not. We use init script 
- size is also issue with user data script
- their are 4 pyhon script that come with amzone AMI, you can also use yum to install it non Linux system
  - ***cfn-init***: Used to retrive and interpret the resource metadata, installing packages, creating files and starting services.
  - ***cfn-signal***: A simple wrapper to signal with a CreationPolicy or WaitCondition, enabling you to synchronize other srsources in the stack with the application being ready.
  - ***cfn-get-metadata***: A wrapper script making it easy to retrive either all metadata defined for a resource ot path to a specific key or subtee of the resource metadata.
  - ***cnf-hup***: Run as demonset to check for updates to the metadata and execute custom hooks when the changes are detected, allow you to update the configuration(EC2) by editing the AWS::CloudFormation::Init: metadata and updating your AWS::StackName
  
  ```
  UserData:
  Fn::Base64:
    !Sub |
      #!/bin/bash -xe
      yum update -y aws-cfn-bootstrap
      /opt/aws/bin/cfn-init -v --stack ${AWS::StackName} --resource LaunchConfig --configsets wordpress_install --region ${AWS::Region}
      /opt/aws/bin/cfn-signal -e $? --stack ${AWS::StackName} --resource WebServerGroup --region ${AWS::Region}
  ```
 - **Metata Metadata Type: AWS::EC2::Instance** 


 ```
 Resources: 
  MyInstance: 
    Type: AWS::EC2::Instance
    Metadata: 
      AWS::CloudFormation::Init: 
        config: 
          packages: ==> used to install packages
            :
          groups: ==> used to create groups 
            :
          users: ==> used to create user
            :
          sources: ==> to download data fron source location
            :
          files: ==> to create file , or use remote file
            :
          commands: ==> to run the commands or custom screipt
            :
          services: ==> to start the services 
            :
    Properties: 
      :

 ```
 - **ConfigSet:** By defaut ec2 metadata processing in following order
      - packages
      - groups 
      - users
      - sources
      - files 
      - commands
      - services 
    - if you require diferent order you can use of COnfigSet
  ```
  AWS::CloudFormation::Init: 
  configSets:
    InstallAllandRun: {==Key and then order }
      - "config1"
      - "config2"
    ascending: 
      - "config1"
      - "config2"
    descending: 
      - "config2"
      - "config1"
  config1: 
    commands: 
      test: 
        command: "echo \"$CFNTEST\" > test.txt"
        env: 
          CFNTEST: "I come from config1."
        cwd: "~"
  config2: 
    commands: 
      test: 
        command: "echo \"$CFNTEST\" > test.txt"
        env: 
          CFNTEST: "I come from config2"
        cwd: "~"
  ```



 - ***Creation Policy*** to wait 15M for execution of user data 
 
 ```
 Resources:
  WebServerInstance:
    Type: AWS::EC2::Instance
    CreationPolicy:
      ResourceSignal:
        Count: 1
        Timeout: PT10M
    Metadata:
      AWS::CloudFormation::Init:
        config:
          packages:
            yum:
              nginx: []
          services:
            sysvinit:
              nginx:
                enabled: true
                ensureRunning: true
                files:
                  - /etc/nginx/nginx.conf
                sources:
                  - /usr/share/nginx/html
    Properties:
      InstanceType: t2.micro
      ImageId: !Ref ImageId
      SecurityGroupIds: 
        - !Ref WebServerSecurityGroup
      SubnetId: !Ref SubnetId
      IamInstanceProfile: !Ref InstanceProfile
      Tags:
        - Key: Name
          Value: !Sub '${AWS::StackName}-WebServer'
      UserData:
        Fn::Base64: !Sub |
          #!/bin/bash -xe
          yum update -y
          yum install -y aws-cfn-bootstrap

          amazon-linux-extras enable nginx1

          /opt/aws/bin/cfn-init -v --stack ${AWS::StackName} --resource WebServerInstance --region ${AWS::Region}

          /opt/aws/bin/cfn-signal -e $? --stack ${AWS::StackName} --resource WebServerInstance --region ${AWS::Region}

  WebServerRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: 2012-10-17
        Statement:
          - 
            Effect: Allow
            Principal:
              Service:
                - ec2.amazonaws.com
            Action:
              - sts:AssumeRole
      Policies:
        -
          PolicyName: WebsiteBucketAccess
          PolicyDocument:
            Version: 2012-10-17
            Statement:
              - 
                Effect: Allow
                Action:
                  - 's3:Get*'
                Resource:
                  - !Sub 'arn:aws:s3:::${WebsiteBucket}/*'

  InstanceProfile:
    Type: AWS::IAM::InstanceProfile
    Properties:
      Roles:
        - !Ref WebServerRole

Outputs:
  WebServerPublicDNS:
    Description: Public DNS name of the web server instance
    Value: !GetAtt WebServerInstance.PublicDnsName
 ```
***AWS::CloudFormation::Authentication:*** in metadata 
```

Resources:
  WebServerInstance:
    Type: AWS::EC2::Instance
    CreationPolicy:
      ResourceSignal:
        Count: 1
        Timeout: PT10M
    Metadata:
      AWS::CloudFormation::Authentication:
        WebsiteBucketCredentials:
          type: S3
          buckets:
            - !Ref WebsiteBucket
          roleName: !Ref WebServerRole
      AWS::CloudFormation::Init:
        config:
          packages:
            yum:
              nginx: []
          sources:
            /usr/share/nginx/html: !Sub 'https://s3.${AWS::Region}.amazonaws.com/${WebsiteBucket}/my-website.zip'
          
          # Necessary for Windows users!
          commands:
            01_set_source_permissions:
              command: 'sudo chmod ugo+r /usr/share/nginx/html/index.html'
          
          services:
            sysvinit:
              nginx:
                enabled: true
                ensureRunning: true
                files:
                  - /etc/nginx/nginx.conf
                sources:
                  - /usr/share/nginx/html     
    Properties:
      InstanceType: t2.micro
      ImageId: !Ref ImageId
      SecurityGroupIds: 
        - !Ref WebServerSecurityGroup
      SubnetId: !Ref SubnetId
      IamInstanceProfile: !Ref InstanceProfile
      Tags:
        - Key: Name
          Value: !Sub '${AWS::StackName}-WebServer'
      UserData:
        Fn::Base64: !Sub |
          #!/bin/bash -xe
          yum update -y
          yum install -y aws-cfn-bootstrap

          amazon-linux-extras enable nginx1

          /opt/aws/bin/cfn-init -v --stack ${AWS::StackName} --resource WebServerInstance --region ${AWS::Region}

          /opt/aws/bin/cfn-signal -e $? --stack ${AWS::StackName} --resource WebServerInstance --region ${AWS::Region}

  WebServerRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: 2012-10-17
        Statement:
          - 
            Effect: Allow
            Principal:
              Service:
                - ec2.amazonaws.com
            Action:
              - sts:AssumeRole
      Policies:
        -
          PolicyName: WebsiteBucketAccess
          PolicyDocument:
            Version: 2012-10-17
            Statement:
              - 
                Effect: Allow
                Action:
                  - 's3:Get*'
                Resource:
                  - !Sub 'arn:aws:s3:::${WebsiteBucket}/*'

  InstanceProfile:
    Type: AWS::IAM::InstanceProfile
    Properties:
      Roles:
        - !Ref WebServerRole

Outputs:
  WebServerPublicDNS:
    Description: Public DNS name of the web server instance
    Value: !GetAtt WebServerInstance.PublicDnsName
```
## Finally 
```
AWSTemplateFormatVersion: '2010-09-09'
Description: AWS CloudFormation Sample Template for CFN Init
Parameters:
  KeyName:
    Description: Name of an existing EC2 KeyPair to enable SSH access to the instances
    Type: AWS::EC2::KeyPair::KeyName
    ConstraintDescription: must be the name of an existing EC2 KeyPair.
  SSHLocation:
    Description: The IP address range that can be used to SSH to the EC2 instances
    Type: String
    MinLength: '9'
    MaxLength: '18'
    Default: 0.0.0.0/0
    AllowedPattern: "(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})/(\\d{1,2})"
    ConstraintDescription: must be a valid IP CIDR range of the form x.x.x.x/x.

Resources:
  WebServerSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Enable HTTP access via port 80 and SSH access via port 22
      SecurityGroupIngress:
      - IpProtocol: tcp
        FromPort: '80'
        ToPort: '80'
        CidrIp: 0.0.0.0/0
      - IpProtocol: tcp
        FromPort: '22'
        ToPort: '22'
        CidrIp: !Ref SSHLocation

  WebServerHost:
    Type: AWS::EC2::Instance
    Metadata:
      Comment: Install a simple PHP application
      AWS::CloudFormation::Init:
        config:
          packages:
            yum:
              httpd: []
              php: []
          groups:
            apache: {}
          users:
            "apache":
              groups:
                - "apache"
          sources:
            "/home/ec2-user/aws-cli": "https://github.com/aws/aws-cli/tarball/master"
          files:
            "/tmp/cwlogs/apacheaccess.conf":
              content: !Sub |
                [general]
                state_file= /var/awslogs/agent-state
                [/var/log/httpd/access_log]
                file = /var/log/httpd/access_log
                log_group_name = ${AWS::StackName}
                log_stream_name = {instance_id}/apache.log
                datetime_format = %d/%b/%Y:%H:%M:%S
              mode: '000400'
              owner: apache
              group: apache
            "/var/www/html/index.php":
              content: !Sub |
                <?php
                echo '<h1>AWS CloudFormation sample PHP application for ${AWS::StackName}</h1>';
                ?>
              mode: '000644'
              owner: apache
              group: apache
            "/etc/cfn/cfn-hup.conf":
              content: !Sub |
                [main]
                stack=${AWS::StackId}
                region=${AWS::Region}
              mode: "000400"
              owner: "root"
              group: "root"
            "/etc/cfn/hooks.d/cfn-auto-reloader.conf":
              content: !Sub |
                [cfn-auto-reloader-hook]
                triggers=post.update
                path=Resources.WebServerHost.Metadata.AWS::CloudFormation::Init
                action=/opt/aws/bin/cfn-init -v --stack ${AWS::StackName} --resource WebServerHost --region ${AWS::Region}
              mode: "000400"
              owner: "root"
              group: "root"
          commands:
            test:
              command: "echo \"$MAGIC\" > test.txt"
              env:
                MAGIC: "I come from the environment!"
              cwd: "~"
          services:
            sysvinit:
              httpd:
                enabled: 'true'
                ensureRunning: 'true'
              sendmail:
                enabled: 'false'
                ensureRunning: 'false'
    CreationPolicy:
      ResourceSignal:
        Timeout: PT5M
    Properties:
      ImageId: ami-a4c7edb2
      KeyName:
        Ref: KeyName
      InstanceType: t2.micro
      SecurityGroups:
      - Ref: WebServerSecurityGroup
      UserData:
        "Fn::Base64":
          !Sub |
            #!/bin/bash -xe
            # Get the latest CloudFormation package
            yum update -y aws-cfn-bootstrap
            # Start cfn-init
            /opt/aws/bin/cfn-init -s ${AWS::StackId} -r WebServerHost --region ${AWS::Region} || error_exit 'Failed to run cfn-init'
            # Start up the cfn-hup daemon to listen for changes to the EC2 instance metadata
            /opt/aws/bin/cfn-hup || error_exit 'Failed to start cfn-hup'
            # All done so signal success
            /opt/aws/bin/cfn-signal -e $? --stack ${AWS::StackId} --resource WebServerHost --region ${AWS::Region}

Outputs:
  InstanceId:
    Description: The instance ID of the web server
    Value:
      Ref: WebServerHost
  WebsiteURL:
    Value:
      !Sub 'http://${WebServerHost.PublicDnsName}'
    Description: URL for newly created LAMP stack
  PublicIP:
    Description: Public IP address of the web server
    Value:
      !GetAtt WebServerHost.PublicIp

```
# Nested Template 
- Reusable workflow