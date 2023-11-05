# AWS deployment

## Terraform codebase

The infrastructure is managed using [Terraform](https://terraform.io), to deploy the infrastructure from a codebase and handle changes in the configuration.
The codebase can be found in the [`infrastructure`](/infrastructure/) folder.

### Directory hierarchy

- The directories in the [`environment`](/infrastructure/environment/) directory contain Terraform layers related to each environment: production only for now. They either reference resources directly, or call Terraform modules for less code repetition.
- The directories in the [`modules`](/infrastructure/modules/) directory contain Terraform modules that accept inputs as variables, and define a specific aspect of the infrastructure. As an example, by calling the [`state`](/infrastructure/modules/state/) module, each environment has an identical setup regarding Terraform state S3 buckets and DynamoDB tables.

## How to deploy the infrastructure

#### Setup Direnv

This repo is configured using [`direnv`](https://direnv.net/), which is a tool that can automatically update your environment variables based on the directory that you're currently in.

#### Log into AWS

Use `aws configure sso` to log into your AWS account using IAM Identity Center. MFA is mandatory.

#### Run Terraform

Follow these steps:

- go to the [`infrastructure/environment/prod`](/infrastructure/environment/prod/) folder;
- initialize your Terraform repo and its dependencies by running `terraform init`.
  > It is recommended to use [`tfswitch`](https://tfswitch.warrensbox.com/) first to make sure that you use the proper Terraform version.
- run a Terraform plan to validate your changes and make sure that they are as expected, using `terraform plan`;
- if the changes Terraform suggests are OK, apply them by running `terraform apply`, then typing `yes` and pressing <kbd>Enter</kbd>.

Terraform will automatically deploy the infrastructure described in [infrastructure.md](infrastructure.md).

## How to deploy the applications

Run the following scripts:

```bash
./scripts/aws/bootstrap.sh # Sets up your kubeconfig for connection through bastion, and sets up Traefik and Cluster Autoscaler
./scripts/aws/build.sh     # Builds `hello` and `world` Docker images and pushes them to AWS ECR
./scripts/aws/deploy.sh    # Deploys the `hello` and `world` Helm charts
```

You can update the applications at any time by running the two last scripts again.

The `scripts/aws/bootstrap.sh` script needs to be run only once. If you need to reconfigure your kubeconfig, run:

```bash
./scripts/aws/setup_kubectl.sh
```

## Destroy the infrastructure

> ⚠️ This is a dangerous operation!

Go to the [`infrastructure/environment/prod`](/infrastructure/environment/prod/) folder, then run `terraform destroy`.

Please note that the VPC subnets and the Internet gateway might not be deleted properly after running the command, because the load balancer created by the AWS cloud provider load balancer controller are not managed via Terraform. You can delete them directly via the AWS console, then rerun the command.
