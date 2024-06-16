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
  - ```
  UserData:
  Fn::Base64:
    !Sub |
      #!/bin/bash -xe
      yum update -y aws-cfn-bootstrap
      /opt/aws/bin/cfn-init -v --stack ${AWS::StackName} --resource LaunchConfig --configsets wordpress_install --region ${AWS::Region}
      /opt/aws/bin/cfn-signal -e $? --stack ${AWS::StackName} --resource WebServerGroup --region ${AWS::Region}
  ```
# Nested Template 
- Reusable workflow