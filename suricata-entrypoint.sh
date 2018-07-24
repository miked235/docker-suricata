#!/bin/bash
# Suricata entrypoint script

set -e

if [ ! -d "/logs/suricata" ]; then
  mkdir /logs/suricata
fi

sleep 10

if [ "$RULES_UPDATER" = "true" ]
then
  # Get list of Suricata Pods - requires RBAC
  SURICATA_PODS=`kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' -l app=suricata | grep $CHART_PREFIX`
  
  # Update rules
  suricata-update
  
  # Reload Suricata rules
  for pod in $SURICATA_PODS
  do
    kubectl exec $pod -c suricata -- suricatasc -c reload-rules
    sleep 10 
  done
else 
  # Start Suricata normally
  suricata -c /etc/suricata/suricata.yaml --af-packet
fi
