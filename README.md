# hello-world spring-boot
[![Java CI with Gradle](https://github.com/LenCompan/test-cheerz-springboot/actions/workflows/gradle.yml/badge.svg)](https://github.com/LenCompan/test-cheerz-springboot/actions/workflows/gradle.yml)

## Livrables
- Instructions de déploiement
- URL de l'application déployée
- Justification du choix de plateforme (3-5 lignes)
- Améliorations possibles

# Url de l'application
L'application se trouver ici : [https://cheerz.nephi.fr/](https://cheerz.nephi.fr/)


# Justification du choix de la plateforme

GKE a été séléctionné pour coller au plus près à la stack de cheerz ainsi qu'aux compétences attendues.
Le choix de la platforme a été une erreur, j'aurais perdu moins de temps avec un environnement que je connais déjà.
Concernant la platforme, les critères de séléction général sont:
 - Les coûts / performances / stabilité
 - La qualité de la documentation.
 - L'intégration avec les process déjà existant.
 - L'éthique et la gestion de l'energie du provider.

# Instructions de déploiement

## Local

Build de l'application:

```bash
./gradlew build
```

Vous pouvez également build en utilisant docker directement:
```bash
docker run -it --rm -v ./:/app -w /app --entrypoint "" eclipse-temurin:17-jdk ./gradlew build
```

Build de l'image en local:

```bash
docker build . -t test-cheerz-springboot:local
```

Vous pouvez utiliser ce `docker-compose.yaml` pour ensuite boot
l'application

```yaml
services:
  web:
    image: test-cheerz-springboot:local
    container_name: test-cheerz-springboot_local
    ports:
      - "8080:8080"
```

Ou directement en cli:
```bash
docker run --rm -p 8080:8080 test-cheerz-springboot:local
```

Et la tester via:

```bash
curl localhost:8080
```

## Deployment Kube

Ajouter ces Deploiement, Service et Ingress à votre cluster via `kubectl apply -f your_yaml.yaml`
### Deploiement
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-1
  namespace: namespace-example
  labels:
    app: deployment-1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: deployment-1
  template:
    metadata:
      labels:
        app: deployment-1
    spec:
      containers:
        - name: test-cheerz-springboot-1
          image: ghcr.io/lencompan/test-cheerz-springboot:latest
          ports:
            - containerPort: 8080
              protocol: TCP
          resources:
            limits:
              cpu: 1000m
              memory: 4Gi
            requests:
              cpu: 500m
              memory: 2Gi

```

### Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: deployment-service-1
  namespace: namespace-example
spec:
  selector:
    app: deployment-service-1
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080

```

### Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  namespace: hello-world
  annotations:
    kubernetes.io/ingress.class: gce
    kubernetes.io/ingress.allow-http: "true"
    kubernetes.io/ingress.global-static-ip-name: app-ingress-ip
    cert-manager.io/issuer: letsencrypt-production
spec:
  defaultBackend:
    service:
      name: deployment-service-1
      port:
        number: 8080
```

# Optimizations
 - Mettre un job de check de syntax du code en premier (via sonarqube par exemple).
 - Checker l'intégrité/vulnérabilitées des images avec `docker scout` ou `snyk`
 - Mettre du cache dans la CI pour rendre les jobs plus rapide.
 - Build on tag/release, afin de préserver des ressources et d'avoir un semver cohérent.
 - Ajouter des labels à l'image pour les utiliser dans la CI
 - Utiliser `FluxCD` pour avoir une logique de pull des images vers le cluster.
 - Faire une image distroless/rootless et donc:
    - Prévoir une image sidecar pour aider au debug occasionnel.
 - Mesurer les utilisations cpu/ram plus précisement pour les requests/limits
 - Ajouter des Healthcheck ex: `curl localhost:8080`
 - Ajouter un EXPOSE 8080 dans le Dockerfile pour mieux documenter.
 - etc.

# Notes:
 - L'image de base a été changée de `openjdk:8-jdk-alpine` à `eclipse-temurin:17-jdk-alpine` afin de pouvoir build.
 Comme vu dans cette [PR](https://github.com/spring-guides/gs-spring-boot-docker/pull/111)

 - Dans un scénario réel, j'aurais sûrement créé une/de multiples branches pour faire des reviews et éviter de commit
 sur `main`directement.

 - C'était ma première utilisation de GKE et GitHub actions. Le setup a pu prendre un peu de temps. Je suis plus habitué
à `AWS` et `Gitlab CI`