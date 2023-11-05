# Minikube deployment

## Setup

Run the following commands.

```bash
./scripts/minikube/bootstrap.sh # Installs and starts Minikube with Traefik as Ingress Controller
./scripts/minikube/build.sh     # Builds `hello` and `world` Docker images and loads them into Minikube
./scripts/minikube/deploy.sh    # Deploys the `hello` and `world` Helm charts
```

You can update the applications at any time by running the two last scripts again.

## Exposing Traefik

To access the `ornikar.dev/hello` and `ornikar.dev/world` URLs, follow these steps:

- run `minikube tunnel` to expose the Traefik service on ports 80 and 443;
- add the following lines to your `/etc/hosts` file:
  ```
  127.0.0.1 ornikar.dev
  ```
- try sending requests with the following commands:
  ```
  curl -v ornikar.dev/hello
  curl -v ornikar.dev/world
  ```
- you should see `Hello` and `World` respectively.

You can also expose specific services on random local ports with the `minikube service <SERVICE_NAME>` command.

## Teardown

Once you're done, you can destroy your Minikube cluster with the following script:

```bash
./scripts/minikube/teardown.sh
```
