import * as cdk from 'aws-cdk-lib';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as rds from 'aws-cdk-lib/aws-rds';

// App のインスタンスを作成
const app = new cdk.App();

const stack = new cdk.Stack(app, 'MyStack');

// Create VPC
const vpc = ec2.Vpc.fromLookup(stack, 'VPC', {
  vpcId: 'vpc-086fda09865be1dac'
});

// Create RDS Instance
const rdsInstance = new rds.DatabaseInstance(stack, 'RDSInstance', {
  engine: rds.DatabaseInstanceEngine.postgres({
    version: rds.PostgresEngineVersion.VER_16_3
  }),
  instanceType: ec2.InstanceType.of(ec2.InstanceClass.BURSTABLE3, ec2.InstanceSize.MEDIUM),
  vpc,
  vpcSubnets: {
    subnetGroupName: 'default-vpc-086fda09865be1dac'
  },
  databaseName: '',
  credentials: {
    username: 'postgres'
  },
  allocatedStorage: 50,
  backupRetention: cdk.Duration.days(7),
  monitoringInterval: cdk.Duration.minutes(60),
  monitoringRole: {
    roleArn: 'arn:aws:iam::835008509196:role/rds-monitoring-role'
  },
  parameterGroup: rds.ParameterGroup.fromParameterGroupName(stack, 'ParameterGroup', 'default.postgres16'),
  optionGroup: rds.OptionGroup.fromOptionGroupName(stack, 'OptionGroup', 'default:postgres-16'),
  maxAllocatedStorage: 1000,
  securityGroups: [
    ec2.SecurityGroup.fromSecurityGroupId(stack, 'RDSSecurityGroup', 'sg-00e24a5ddd4ce43b8'),
    ec2.SecurityGroup.fromSecurityGroupId(stack, 'EC2RDSSecurityGroup', 'sg-0044c07fc3a057fd9')
  ],
  certificateAuthority: rds.CertificateAuthority.fromCertificateAuthorityArn(stack, 'CertificateAuthority', 'rds-ca-rsa2048-g1')
});

// Create EC2 Key Pair
const ec2KeyPair = new ec2.CfnKeyPair(stack, 'EC2KeyPair', {
  keyName: 'c2c-test-ec2-key-pair',
  keyType: 'rsa',
  keyFormat: 'pem'
});

// Create Security Group for EC2 Instance
const ec2SecurityGroup = new ec2.SecurityGroup(stack, 'EC2SecurityGroup', {
  vpc,
  securityGroupName: 'launch-wizard-2',
  description: 'launch-wizard-2 created 2024-10-13T07:40:32.737Z',
  allowAllOutbound: false
});
ec2SecurityGroup.addIngressRule(ec2.Peer.anyIpv4(), ec2.Port.tcp(22), 'Allow SSH access');

// Create EC2 Instance
const ec2Instance = new ec2.Instance(stack, 'EC2Instance', {
  vpc,
  instanceType: ec2.InstanceType.of(ec2.InstanceClass.BURSTABLE2, ec2.InstanceSize.MICRO),
  machineImage: ec2.MachineImage.latestAmazonLinux(),
  keyName: ec2KeyPair.keyName,
  securityGroup: ec2SecurityGroup,
  associatePublicIpAddress: true,
  creditSpecification: {
    cpuCredits: ec2.CpuCredits.STANDARD
  },
  metadataOptions: {
    httpEndpoint: ec2.InstanceMetadataEndpointService.ENABLED,
    httpPutResponseHopLimit: 2,
    httpTokens: ec2.InstanceMetadataHttpTokens.REQUIRED
  },
  privateDnsNameOptions: {
    hostnameType: ec2.HostnameType.IP_NAME,
    enableResourceNameDnsARecord: true,
    enableResourceNameDnsAAAARecord: false
  }
});
ec2Instance.node.addDependency(ec2SecurityGroup);
ec2Instance.node.addDependency(rdsInstance);

// Create Security Group for EC2 to RDS communication
const ec2ToRdsSecurityGroup = new ec2.SecurityGroup(stack, 'EC2ToRDSSecurityGroup', {
  vpc,
  securityGroupName: 'ec2-rds-1',
  description: 'Security group attached to instances to allow them to securely connect to c2c-test-db. Modification could lead to connection loss.'
});

// Create Security Group for RDS to EC2 communication
const rdsToEc2SecurityGroup = new ec2.SecurityGroup(stack, 'RDSToEC2SecurityGroup', {
  vpc,
  securityGroupName: 'rds-ec2-1',
  description: 'Security group attached to c2c-test-db to allow EC2 instances with specific security groups attached to connect to the database. Modification could lead to connection loss.'
});

// Allow RDS to EC2 communication
rdsToEc2SecurityGroup.addEgressRule(ec2ToRdsSecurityGroup, ec2.Port.tcp(5432), 'Allow RDS to EC2 communication');
ec2ToRdsSecurityGroup.addIngressRule(rdsToEc2SecurityGroup, ec2.Port.tcp(5432), 'Allow EC2 to RDS communication');

// Revoke default egress rules
rdsToEc2SecurityGroup.revokeEgressRule(ec2.Peer.anyIpv4(), ec2.Port.allTraffic());
ec2ToRdsSecurityGroup.revokeEgressRule(ec2.Peer.anyIpv4(), ec2.Port.allTraffic());

// Associate Security Groups with EC2 Instance
ec2Instance.instance.addSecurityGroup(ec2ToRdsSecurityGroup);
