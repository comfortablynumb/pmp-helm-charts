# Application Helm Chart

A comprehensive Helm chart for deploying containerized applications to Kubernetes with support for Deployments, CronJobs, autoscaling, and extensive configuration options.

## Features

- **Deployment**: Create a Deployment with configurable replicas, resources, and volumes
- **Horizontal Pod Autoscaler**: Automatic scaling based on CPU, memory, or custom metrics
- **Pod Disruption Budget**: Ensure high availability during voluntary disruptions
- **Service**: Expose your application with configurable service types
- **Ingress**: Configure external access with TLS support
- **CronJobs**: Schedule multiple recurring jobs with independent configurations
- **ConfigMaps & Secrets**: Manage application configuration and sensitive data
- **ServiceAccount**: Configure Kubernetes service accounts with RBAC support

## Installation

### Prerequisites

- Kubernetes 1.19+
- Helm 3.0+

### Basic Installation

```bash
helm install my-app ./charts/application \
  --set image.repository=my-docker-repo/my-app \
  --set image.tag=1.0.0
```

### Installation with Custom Values

```bash
helm install my-app ./charts/application -f my-values.yaml
```

## Configuration

### Global Image Settings

These settings apply to all resources unless overridden at the resource level:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Default Docker image repository | `""` |
| `image.tag` | Default image tag | `""` |
| `image.pullPolicy` | Default image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Image pull secrets for private registries | `[]` |

### Deployment Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `deployment.enabled` | Enable/disable Deployment | `true` |
| `deployment.image.repository` | Override image repository for Deployment | `""` (uses global) |
| `deployment.image.tag` | Override image tag for Deployment | `""` (uses global) |
| `deployment.replicaCount` | Number of replicas when autoscaling is disabled | `1` |
| `deployment.containerPort` | Container port | `8080` |
| `deployment.resources.limits.cpu` | CPU limit | `1000m` |
| `deployment.resources.limits.memory` | Memory limit | `512Mi` |
| `deployment.resources.requests.cpu` | CPU request | `100m` |
| `deployment.resources.requests.memory` | Memory request | `128Mi` |

**Note**: All pods (Deployment and CronJobs) automatically include the `KUBERNETES_NODE_IP` environment variable, which is populated with the node's IP address using the Kubernetes downward API.

### Autoscaling Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `autoscaling.enabled` | Enable Horizontal Pod Autoscaler | `false` |
| `autoscaling.minReplicas` | Minimum number of replicas | `1` |
| `autoscaling.maxReplicas` | Maximum number of replicas | `10` |
| `autoscaling.metrics` | Array of metric specifications | CPU at 80% |

### Pod Disruption Budget

| Parameter | Description | Default |
|-----------|-------------|---------|
| `podDisruptionBudget.enabled` | Enable PodDisruptionBudget | `false` |
| `podDisruptionBudget.minAvailable` | Minimum available pods | `1` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.enabled` | Enable Service | `true` |
| `service.type` | Service type (ClusterIP, NodePort, LoadBalancer) | `ClusterIP` |
| `service.port` | Service port | `80` |
| `service.targetPort` | Target port | `8080` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable Ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts` | Array of host configurations | See values.yaml |
| `ingress.tls` | TLS configuration | `[]` |

### CronJob Configuration

CronJobs are configured as an array, allowing multiple scheduled jobs:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `cronJobs[].name` | Name of the CronJob | Required |
| `cronJobs[].schedule` | Cron schedule expression | Required |
| `cronJobs[].image.repository` | Override image repository | `""` (uses global) |
| `cronJobs[].image.tag` | Override image tag | `""` (uses global) |
| `cronJobs[].command` | Command to execute | `[]` |
| `cronJobs[].resources` | Resource limits and requests | See values.yaml |
| `cronJobs[].concurrencyPolicy` | Concurrency policy | `Forbid` |

### Secrets Configuration

Secrets are configured as an array, allowing multiple secrets with custom names:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `secrets[].name` | Name of the Secret | Required |
| `secrets[].type` | Secret type | `Opaque` |
| `secrets[].annotations` | Annotations to add to the Secret | `{}` |
| `secrets[].labels` | Labels to add (in addition to chart labels) | `{}` |
| `secrets[].data` | Secret data (key-value pairs, auto base64 encoded) | `{}` |

## Usage Examples

### Example 1: Simple Web Application

```yaml
image:
  repository: nginx
  tag: "1.21"

deployment:
  enabled: true
  containerPort: 80
  resources:
    limits:
      cpu: 500m
      memory: 256Mi
    requests:
      cpu: 100m
      memory: 128Mi

service:
  enabled: true
  type: ClusterIP
  port: 80
  targetPort: 80
```

### Example 2: Application with Autoscaling

```yaml
image:
  repository: my-app
  tag: "2.0.0"

deployment:
  enabled: true
  resources:
    limits:
      cpu: 2000m
      memory: 1Gi
    requests:
      cpu: 500m
      memory: 512Mi

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80

podDisruptionBudget:
  enabled: true
  minAvailable: 1
```

### Example 3: Application with CronJobs

```yaml
image:
  repository: my-app
  tag: "1.0.0"

deployment:
  enabled: true

cronJobs:
  - name: daily-backup
    schedule: "0 2 * * *"
    command:
      - /bin/sh
      - -c
      - ./backup.sh
    resources:
      limits:
        cpu: 500m
        memory: 256Mi
      requests:
        cpu: 100m
        memory: 128Mi

  - name: hourly-cleanup
    schedule: "0 * * * *"
    command:
      - /bin/sh
      - -c
      - ./cleanup.sh
    resources:
      limits:
        cpu: 200m
        memory: 128Mi
      requests:
        cpu: 50m
        memory: 64Mi
```

### Example 4: Application with Ingress and TLS

```yaml
image:
  repository: my-web-app
  tag: "1.5.0"

deployment:
  enabled: true

service:
  enabled: true
  type: ClusterIP
  port: 80

ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: myapp-tls
      hosts:
        - myapp.example.com
```

### Example 5: Application with ConfigMap and Secrets

```yaml
image:
  repository: my-app
  tag: "1.0.0"

deployment:
  enabled: true
  envFrom:
    - configMapRef:
        name: my-app-release-application
    - secretRef:
        name: app-secrets

configMap:
  enabled: true
  data:
    APP_ENV: production
    LOG_LEVEL: info
    config.yaml: |
      server:
        port: 8080
        host: 0.0.0.0

secrets:
  - name: app-secrets
    type: Opaque
    data:
      database-password: mySecretPassword123
      api-key: myApiKey456
```

### Example 6: Application with Multiple Secrets

```yaml
image:
  repository: my-app
  tag: "1.0.0"

deployment:
  enabled: true
  envFrom:
    # Reference secrets explicitly
    - secretRef:
        name: app-config
    - secretRef:
        name: database-credentials
    - secretRef:
        name: third-party-api-keys

# All secrets configured in the secrets array
secrets:
  - name: app-config
    type: Opaque
    data:
      APP_SECRET_KEY: myAppSecretKey123

  - name: database-credentials
    type: Opaque
    annotations:
      description: "Database connection credentials"
    labels:
      app.kubernetes.io/component: database
    data:
      DB_HOST: postgres.example.com
      DB_PORT: "5432"
      DB_USERNAME: app_user
      DB_PASSWORD: super_secret_password
      DB_NAME: production_db

  - name: third-party-api-keys
    type: Opaque
    annotations:
      description: "Third-party service API keys"
    labels:
      app.kubernetes.io/component: integrations
    data:
      STRIPE_API_KEY: sk_live_xxxxxxxxxxxxx
      SENDGRID_API_KEY: SG.xxxxxxxxxxxxx
      AWS_ACCESS_KEY_ID: AKIA_xxxxxxxxxxxxx
      AWS_SECRET_ACCESS_KEY: super_secret_aws_key
```

## Upgrading

```bash
helm upgrade my-app ./charts/application -f my-values.yaml
```

## Uninstalling

```bash
helm uninstall my-app
```

## Contributing

Contributions are welcome! Please submit pull requests or issues to the repository.

## License

This Helm chart is available under the MIT License. See the LICENSE file for more information.
