# Welcome to your CDK TypeScript project

This is a blank project for CDK development with TypeScript.

The `cdk.json` file tells the CDK Toolkit how to execute your app.

## Useful commands

* `npm run build`   compile typescript to js
* `npm run watch`   watch for changes and compile
* `npm run test`    perform the jest unit tests
* `npx cdk deploy`  deploy this stack to your default AWS account/region
* `npx cdk diff`    compare deployed stack with current state
* `npx cdk synth`   emits the synthesized CloudFormation template



``` sh
aws rds create-db-instance --engine "postgres" --engine-version "16.3" --engine-lifecycle-support "open-source-rds-extended-support-disabled" --db-instance-identifier "c2c-test-db" --master-username "postgres" --db-instance-class "db.t3.medium" --db-subnet-group-name "default-vpc-086fda09865be1dac" --db-name "" --character-set-name 'null' --nchar-character-set-name 'null' --vpc-security-group-ids "sg-00e24a5ddd4ce43b8" --db-security-groups 'null' --availability-zone 'null' --port "5432" --storage-type "gp3" --allocated-storage "50" --iops 'null' --storage-throughput 'null' --kms-key-id 'null' --preferred-maintenance-window 'null' --preferred-backup-window 'null' --backup-retention-period "7" --performance-insights-kmskey-id 'null' --performance-insights-retention-period "7" --monitoring-role-arn "arn:aws:iam::835008509196:role/rds-monitoring-role" --monitoring-interval "60" --domain 'null' --domain-iam-role-name 'null' --domain-fqdn 'null' --domain-ou 'null' --domain-auth-secret-arn 'null' --domain-dns-ips 'null' --db-parameter-group-name "default.postgres16" --option-group-name "default:postgres-16" --timezone 'null' --processor-features 'null' --max-allocated-storage "1000" --network-type 'null' --backup-target 'null' --ca-certificate-identifier "rds-ca-rsa2048-g1"
aws ec2 create-key-pair --key-name "c2c-test-ec2-key-pair" --key-type "rsa" --key-format "pem"
aws ec2 create-security-group --group-name "launch-wizard-2" --description "launch-wizard-2 created 2024-10-13T07:40:32.737Z" --vpc-id "vpc-086fda09865be1dac"
aws ec2 authorize-security-group-ingress --group-id "sg-0f25f090e6fc89519" --ip-permissions '{"IpProtocol":"tcp","FromPort":22,"ToPort":22,"IpRanges":[{"CidrIp":"0.0.0.0/0"}]}'
aws ec2 run-instances --image-id "ami-0ef29ab52ff72213b" --instance-type "t2.micro" --key-name "c2c-test-ec2-key-pair" --network-interfaces '{"AssociatePublicIpAddress":true,"DeviceIndex":0,"Groups":["sg-0f25f090e6fc89519"]}' --credit-specification '{"CpuCredits":"standard"}' --tag-specifications '{"ResourceType":"instance","Tags":[{"Key":"Name","Value":"c2c-test-ec2"}]}' --metadata-options '{"HttpEndpoint":"enabled","HttpPutResponseHopLimit":2,"HttpTokens":"required"}' --private-dns-name-options '{"HostnameType":"ip-name","EnableResourceNameDnsARecord":true,"EnableResourceNameDnsAAAARecord":false}' --count "1"
aws ec2 create-security-group --group-name "ec2-rds-1" --vpc-id "vpc-086fda09865be1dac" --description "Security group attached to instances to allow them to securely connect to c2c-test-db. Modification could lead to connection loss."
aws ec2 create-security-group --group-name "rds-ec2-1" --vpc-id "vpc-086fda09865be1dac" --description "Security group attached to c2c-test-db to allow EC2 instances with specific security groups attached to connect to the database. Modification could lead to connection loss."
aws ec2 authorize-security-group-egress --group-id "sg-051a4d448a726e06d" --ip-permissions '{"FromPort":5432,"IpProtocol":"tcp","ToPort":5432,"UserIdGroupPairs":[{"Description":"Rule to allow connections to c2c-test-db from any instances this security group is attached to","GroupId":"sg-0044c07fc3a057fd9"}]}'
aws ec2 authorize-security-group-ingress --group-id "sg-0044c07fc3a057fd9" --ip-permissions '{"FromPort":5432,"IpProtocol":"tcp","ToPort":5432,"UserIdGroupPairs":[{"Description":"Rule to allow connections from EC2 instances with sg-051a4d448a726e06d attached","GroupId":"sg-051a4d448a726e06d"}]}'
aws ec2 revoke-security-group-egress --group-id "sg-051a4d448a726e06d" --ip-permissions '{"FromPort":0,"IpProtocol":"all","ToPort":0,"IpRanges":[{"CidrIp":"0.0.0.0/0"}]}'
aws ec2 revoke-security-group-egress --group-id "sg-0044c07fc3a057fd9" --ip-permissions '{"FromPort":0,"IpProtocol":"all","ToPort":0,"IpRanges":[{"CidrIp":"0.0.0.0/0"}]}'
aws ec2 modify-network-interface-attribute --network-interface-id "eni-038422620c5320112" --groups "sg-0f25f090e6fc89519" "sg-051a4d448a726e06d"
aws rds modify-db-instance --db-instance-identifier "c2c-test-db" --vpc-security-group-ids "sg-00e24a5ddd4ce43b8" "sg-0044c07fc3a057fd9"
```

``` sh
❯ aws rds create-db-instance --engine "postgres" --engine-version "16.3" --engine-lifecycle-support "open-source-rds-extended-support-disabled" --db-instance-identifier "c2c-test-db" --master-username "postgres" --db-instance-class "db.t3.medium" --db-subnet-group-name "default-vpc-086fda09865be1dac" --db-name "" --character-set-name 'null' --nchar-character-set-name 'null' --vpc-security-group-ids "sg-00e24a5ddd4ce43b8" --db-security-groups 'null' --availability-zone 'null' --port "5432" --storage-type "gp3" --allocated-storage "50" --iops 'null' --storage-throughput 'null' --kms-key-id 'null' --preferred-maintenance-window 'null' --preferred-backup-window 'null' --backup-retention-period "7" --performance-insights-kmskey-id 'null' --performance-insights-retention-period "7" --monitoring-role-arn "arn:aws:iam::835008509196:role/rds-monitoring-role" --monitoring-interval "60" --domain 'null' --domain-iam-role-name 'null' --domain-fqdn 'null' --domain-ou 'null' --domain-auth-secret-arn 'null' --domain-dns-ips 'null' --db-parameter-group-name "default.postgres16" --option-group-name "default:postgres-16" --timezone 'null' --processor-features 'null' --max-allocated-storage "1000" --network-type 'null' --backup-target 'null' --ca-certificate-identifier "rds-ca-rsa2048-g1"


usage: aws [options] <command> <subcommand> [<subcommand> ...] [parameters]
To see help text, you can run:

  aws help
  aws <command> help
  aws <command> <subcommand> help

Unknown options: --engine-lifecycle-support, --performance-insights-kmskey-id, null, open-source-rds-extended-support-disabled

aws rds create-db-instance --engine "postgres" --engine-version "16.3"  --db-instance-identifier "c2c-test-db" --master-username "postgres" --db-instance-class "db.t3.medium" --db-subnet-group-name "default-vpc-086fda09865be1dac" --db-name "" --character-set-name 'null' --nchar-character-set-name 'null' --vpc-security-group-ids "sg-00e24a5ddd4ce43b8" --db-security-groups 'null' --availability-zone 'null' --port "5432" --storage-type "gp3" --allocated-storage "50" --storage-throughput 'null' --kms-key-id 'null' --preferred-maintenance-window 'null' --preferred-backup-window 'null' --backup-retention-period "7" --performance-insights-retention-period "7" --monitoring-role-arn "arn:aws:iam::835008509196:role/rds-monitoring-role" --monitoring-interval "60" --domain 'null' --domain-iam-role-name 'null' --domain-fqdn 'null' --domain-ou 'null' --domain-auth-secret-arn 'null' --domain-dns-ips 'null' --db-parameter-group-name "default.postgres16" --option-group-name "default:postgres-16" --timezone 'null' --max-allocated-storage "1000" --network-type 'null' --backup-target 'null' --ca-certificate-identifier "rds-ca-rsa2048-g1"

invalid literal for int() with base 10: 'null'
```


``` sh
aws rds create-db-instance --engine "postgres" --engine-version "16.3"  --db-instance-identifier "c2c-test-db" --master-username "postgres" --db-instance-class "db.t3.medium" --db-subnet-group-name "default-vpc-086fda09865be1dac" --db-name "" --character-set-name 'null' --nchar-character-set-name 'null' --vpc-security-group-ids "sg-00e24a5ddd4ce43b8" --db-security-groups 'null' --availability-zone 'null' --port "5432" --storage-type "gp3" --allocated-storage "50" --iops 'null' --storage-throughput 'null' --kms-key-id 'null' --preferred-maintenance-window 'null' --preferred-backup-window 'null' --backup-retention-period "7" --performance-insights-retention-period "7" --monitoring-role-arn "arn:aws:iam::835008509196:role/rds-monitoring-role" --monitoring-interval "60" --domain 'null' --domain-iam-role-name 'null' --domain-fqdn 'null' --domain-ou 'null' --domain-auth-secret-arn 'null' --domain-dns-ips 'null' --db-parameter-group-name "default.postgres16" --option-group-name "default:postgres-16" --timezone 'null' --processor-features 'null' --max-allocated-storage "1000" --network-type 'null' --backup-target 'null' --ca-certificate-identifier "rds-ca-rsa2048-g1"

```
