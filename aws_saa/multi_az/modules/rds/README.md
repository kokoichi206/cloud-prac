# rds

## Usage

### [variables](./variables.tf)

| variable | description                                                                |
| -------- | -------------------------------------------------------------------------- |
| prefix   | The prifix of the service                                                  |
| env      | The environment where the service works (production, staging, development) |

### [outputs](./outputs.tf)

| output   | description                           |
| -------- | ------------------------------------- |
| address  | The address of RDS for EC2 to access  |
| endpoint | The endpoint of RDS for EC2 to access |
