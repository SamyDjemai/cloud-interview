#!/bin/sh
set -e

VERSION_NUMBER="1.0"

SCRIPT_PATH=$(dirname "$0")

# For each chart in the `charts` directory, upgrade the chart
for chart in "$SCRIPT_PATH"/../../charts/*; do
  # Get the chart name from the directory name
  chart_name=$(basename "$chart")

  # Install or upgrade the chart
  echo "🏗 Installing or upgrading $chart_name chart..."
  helm upgrade --install "$chart_name" "$chart" --set image.tag="$VERSION_NUMBER"
  echo "✅ $chart_name chart is installed or upgraded."
done
