#!/bin/bash
# Suricata rules update script

set -e

mkdir -p /data/suricata

# Update rules
suricata-update

# Install Kubectl - REQUIRES RBAC
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl

# Get list of Suricata Pods - REQUIRES RBAC
SURICATA_PODS=`kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' -l app=suricata | grep $CHART_PREFIX`

echo "Found Suricata pods:"
echo "$SURICATA_PODS"

# Reload Suricata rules - REQUIRES RBAC
for pod in $SURICATA_PODS
do
  echo "Reloading rules in $pod"
  kubectl exec $pod -c suricata -- suricatasc -c reload-rules
  sleep 10 
done
 