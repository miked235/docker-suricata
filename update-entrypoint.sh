#!/bin/bash
# Suricata rules update script

set -e

mkdir -p /data/suricata /logs/suricata

sleep 10

# Update rules
suricata-update

# Install Kubectl - REQUIRES RBAC
echo "Installing kubectl..."
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl

# Get list of Suricata Pods - REQUIRES RBAC
echo "Getting list of Suricata Pods..."
SURICATA_PODS=`kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' -l app=suricata | grep $CHART_PREFIX`

echo 
echo "Found Suricata pods:"
echo "$SURICATA_PODS"
echo 

# Reload Suricata rules - REQUIRES RBAC
for pod in $SURICATA_PODS
do
  echo "Reloading rules in $pod"
  kubectl exec $pod -c suricata -- suricatasc -c reload-rules
  sleep 10 
done
 