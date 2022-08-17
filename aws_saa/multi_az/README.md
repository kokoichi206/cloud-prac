# Multi-AZ

AWS-SAA でよくみる構成を作ってみようシリーズ [#17](https://github.com/kokoichi206/cloud-prac/issues/17)

## Architecture

![](./docs/architecture.svg)

## Usage

```sh
# Production deploy
$ terraform apply -var="env=production"
```

### [variables](./variables.tf)

| variable | description                                                                |
| -------- | -------------------------------------------------------------------------- |
| prefix   | The prifix of the service                                                  |
| env      | The environment where the service works (production, staging, development) |

### [outputs](./outputs.tf)

| output              | description               |
| ------------------- | ------------------------- |
| ssh_command         | SSH command to access EC2 |
| sql_connect_command | Command to connect RDS    |

## Modules
