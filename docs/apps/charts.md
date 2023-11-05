# App charts

Each application has its own Helm chart, which simplifies Kubernetes deployment.
The charts create or upgrade the following Kubernetes resources:

- a `Deployment`, which in turn creates Pods that run app images;
- a `HorizontalPodAutoscaler`, which adjusts the Deployment's replica count depending on the current CPU or memory utilization;
- an `Ingress`, that Traefik discovers and uses to redirect traffic to the corresponding application;
- a `Middleware`, based on Traefik's custom CRDs, that strips the app's prefix from the URL: as an example, the `hello` app receives traffic on its internal `/` endpoint although the request was to the `ornikar.dev/hello` URL;
- a `Service`, that exposes the app's port in the cluster;
- a `ServiceAccount`, which is not used in our case but can be used to interact with cloud resources and other cluster resources.

The charts' templates are meant to be as generic as possible. As a result, all values should be edited through the `values.yaml` files.
