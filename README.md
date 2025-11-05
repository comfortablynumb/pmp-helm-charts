# PMP Helm Charts

A collection of Helm charts for deploying applications to Kubernetes.

## Available Charts

- **[application](./charts/application/README.md)**: A comprehensive Helm chart for deploying containerized applications with support for Deployments, CronJobs, autoscaling, and extensive configuration options.

## Installation

### Using the Helm Repository

Once the charts are published to GitHub Pages, you can add this repository:

```bash
helm repo add pmp-helm-charts https://<your-github-username>.github.io/pmp-helm-charts
helm repo update
```

Then install a chart:

```bash
helm install my-app pmp-helm-charts/application \
  --set image.repository=my-docker-repo/my-app \
  --set image.tag=1.0.0
```

### Using Local Charts

You can also install directly from this repository:

```bash
helm install my-app ./charts/application -f my-values.yaml
```

## Publishing Charts

This repository uses GitHub Actions to automatically publish Helm charts to GitHub Pages.

### Setup Instructions

1. **Enable GitHub Pages**:
   - Go to your repository Settings
   - Navigate to Pages (under Code and automation)
   - Set Source to "GitHub Actions"

2. **How It Works**:
   - The workflow triggers on every push to the `main` branch that modifies files in the `charts/` directory
   - It packages the Helm charts and creates GitHub releases
   - Charts are automatically published to GitHub Pages at `https://<your-github-username>.github.io/pmp-helm-charts`

3. **Releasing a New Version**:
   - Update the `version` field in `charts/<chart-name>/Chart.yaml`
   - Commit and push to the `main` branch
   - The GitHub Action will automatically create a release and publish the chart

### Workflow Details

The [release workflow](.github/workflows/release.yml) performs the following steps:

1. Checks out the repository
2. Configures Git for commits
3. Installs Helm
4. Runs `chart-releaser-action` to:
   - Package the charts
   - Create GitHub releases for new chart versions
   - Update the Helm repository index
   - Publish to GitHub Pages

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
