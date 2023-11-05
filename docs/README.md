# Cloud Interview - Ornikar

## Hierarchy

This repo contains:

- [two backend applications](../apps/):
  - a Node.js/Express based backend;
  - a PHP-based application;
- [their corresponding Helm charts](../charts/);
- [the Terraform codebase corresponding to the AWS infrastructure of the project](../infrastructure/);
- [scripts to automate and reproduce deployment on both Minikube and AWS](../scripts/).

## How do I get started?

### Develop and prepare deployment

Read [apps/development.md](apps/development.md) and [apps/charts.md](apps/charts.md)

### Deploy on Minikube (⛅️ Cloud Interview – Test)

Read [minikube/deploy.md](minikube/deploy.md).

### Deploy on AWS

Read [aws/deploy.md](aws/deploy.md). More infrastructure-related information can be found in [aws/infrastructure.md](aws/infrastructure.md).
