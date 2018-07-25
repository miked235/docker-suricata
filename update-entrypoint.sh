#!/bin/bash
# Suricata rules update script

# Update rules
suricata-update

# Get list of Suricata Pods - requires RBAC
SURICATA_PODS=`kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' -l app=suricata | grep $CHART_PREFIX`

# Reload Suricata rules
for pod in $SURICATA_PODS
do
  kubectl exec $pod -c suricata -- suricatasc -c reload-rules
  sleep 10 
done
 