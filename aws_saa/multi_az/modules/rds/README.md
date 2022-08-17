# rds

## Usage

### [variables](./variables.tf)

| variable | description                                                                |
| -------- | -------------------------------------------------------------------------- |
| prefix   | The prifix of the service                                                  |
| env      | The environment where the service works (production, staging, development) |

### [outputs](./outputs.tf)

| output          | description                           |
| --------------- | ------------------------------------- |
| user_name       | Username                              |
| address         | The address of RDS for EC2 to access  |
| address_replica | The address of RDS-Replica            |
| endpoint        | The endpoint of RDS for EC2 to access |
