# ec2

## Usage

### [variables](./variables.tf)

| variable  | description                                                                |
| --------- | -------------------------------------------------------------------------- |
| prefix    | The prifix of the service                                                  |
| env       | The environment where the service works (production, staging, development) |
| vpc_id    | The ID of VPC                                                              |
| subnet_id | The value of subnet_id where ec2 server lives                              |
| key_name  | key name of SSH Key                                                        |

### [outputs](./outputs.tf)

| output    | description                           |
| --------- | ------------------------------------- |
| public_ip | Public IP Address of the ec2 instance |
