#!/bin/sh
set -e

CLUSTER_NAME="samyd-ornikar-prod"

# Get the bastion instance's ID
echo "🔍 Getting the bastion instance's ID..."
BASTION_INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=bastion-1" --query "Reservations[0].Instances[0].InstanceId" --output text)
echo "✅ Bastion instance's ID is $BASTION_INSTANCE_ID"

# Get the EKS cluster's API server endpoint
echo "🔍 Getting EKS cluster's API server endpoint..."
CLUSTER_ENDPOINT=$(aws eks describe-cluster --name "$CLUSTER_NAME" --query "cluster.endpoint" --output text)
# Remove https:// from the beginning of the endpoint
CLUSTER_ENDPOINT=${CLUSTER_ENDPOINT#https://}
echo "✅ EKS cluster's API server endpoint is $CLUSTER_ENDPOINT"

# Add loopback to /etc/hosts if it doesn't exist
# This is needed because we will be port forwarding to the cluster's API server endpoint
# using the bastion instance as a proxy
echo "🔍 Checking if loopback is added to /etc/hosts..."
if ! grep -q "127.0.0.1 $CLUSTER_ENDPOINT" /etc/hosts; then
  echo "❌ Loopback is not added to /etc/hosts. Adding..."
  sudo sh -c "echo '127.0.0.1 $CLUSTER_ENDPOINT' >> /etc/hosts"
fi
echo "✅ Loopback is added to /etc/hosts."

# Update kubeconfig using the AWS CLI
echo "🔁 Updating kubeconfig using the AWS CLI..."
aws eks update-kubeconfig --name "$CLUSTER_NAME"
echo "✅ kubeconfig is updated."

# Update ~/.kube/config to add port number 4443 to the cluster's API server endpoint
# This way, we don't use port 443 on our local machine, which is a privileged port
echo "🔁 Updating ~/.kube/config to add port number 4443 to the cluster's API server endpoint..."
sed -i "s|$CLUSTER_ENDPOINT|$CLUSTER_ENDPOINT:4443|g" ~/.kube/config
echo "✅ ~/.kube/config is updated."

# Check if a previously opened tunnel exists, and if it does, close it
echo "🔍 Checking if previous tunnel exists..."
if [ -S /tmp/samyd-ornikar-tunnel ]; then
  echo "❌ Existing tunnel found. Closing..."
  ssh -S /tmp/samyd-ornikar-tunnel -O exit bastion
fi

# Create a tunnel to the bastion instance using SSH and AWS SSM in the background
echo "🚄 Creating a tunnel to the bastion instance..."
ssh -fNL "4443:$CLUSTER_ENDPOINT:443" -M -S /tmp/samyd-ornikar-tunnel \
  -o ProxyCommand='bash -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters portNumber=%p"' \
  "$BASTION_INSTANCE_ID"

echo "🎉 All done!"
echo "ℹ️  You can now use kubectl to interact with your EKS cluster."
