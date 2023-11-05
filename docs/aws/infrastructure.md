# AWS infrastructure

## Infrastructure diagram

The infrastructure that is deployed using Terraform is shown on the following diagram.

![AWS infrastructure diagram](/docs/.assets/aws_diagram.svg)

## Networking

The infrastructure follows a standard three-tier architecture, using public and private subnets in the AWS sense of the term: a public subnet has a direct route to an internet gateway, while a private subnet requires a NAT gateway to access the internet. This way, resources which are not meant to be public cannot be accessed from the internet.

The following subnets (except for `bastion-1`) are distributed across three availability zones in the `eu-west-3` (Paris) region:

- `pub-1`, `pub-2`, `pub-3`: public subnets for gateways and load balancers;
- `bastion-1`: private subnet that contains a bastion instance with which developers and ops engineers can connect to private resources such as the EKS cluster;
- `app-1`, `app-2`, `app-3`: private subnets for applicative resources, in our case the EKS cluster;
- `data-1`, `data-2`, `data-3`: private subnets that are currently empty, but can be used in the future for databases and other sensitive data-related resources.

### Classic Load Balancer

The Classic Load Balancer exposes Traefik's LoadBalancer Service across all 3 AZs. It is automatically deployed by the AWS cloud provider load balancer controller.

> The Classic Load Balancer is being deprecated by AWS. As such, a next step would be to install the [AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/network-load-balancing.html), to replace it with either a Network Load Balancer (which operates on Layer 4), or an Application Load Balancer (which operates on Layer 7 and can be enhanced with WAF rules, among other high-level features).

### NAT gateway/Internet gateway

All outgoing traffic from the infrastructure goes through the NAT gateway then through the Internet gateway, which has a public IP allocated to it, to which we can refer as the "exit IP address".

## Bastion

The `bastion-1` instance is meant to be used as a jump host to connect to the infrastructure. AWS Systems Manager is an Amazon-managed service that allows infrastructure users to connect to instances without the need to manage SSH keys or credentials other than their AWS credentials.

It is mostly used to connect to the Kubernetes cluster, as demonstrated in the [`scripts/aws/setup_kubectl.sh`](/scripts/aws/setup_kubectl.sh) script.

## EKS cluster

The EKS (Elastic Kubernetes Service) cluster is a managed Kubernetes cluster. Its endpoint is private and cannot be accessed from the internet: as a result, it is necessary to use the bastion instance for operations.

Several AWS-managed addons have been added:

- **Kube-proxy**
  - Maintains network rules on each Amazon EC2 node. It enables network communication to the Pods.
- **Amazon VPC CNI plugin for Kubernetes**
  - A Kubernetes container network interface (CNI) plugin that provides native VPC networking for the cluster.
- **CoreDNS**
  - The DNS service that is used to provide name resolution for all Pods in the cluster.

### Cluster Autoscaler

[Cluster Autoscaler](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md) automatically adjusts the desired size of the EKS cluster depending on the number of pods that couldn't run due to insufficient resources, and the number of nodes that have been underutilized for a while.

### Elastic Container Registry (ECR)

The EKS cluster pulls its Docker images from private ECR repositories, to which applicative images are pushed using the [`scripts/aws/build.sh`](/scripts/aws/build.sh) script.

## Terraform-related resources

An S3 bucket and a DynamoDB table are deployed in order to store the Terraform state and lock it respectively.
