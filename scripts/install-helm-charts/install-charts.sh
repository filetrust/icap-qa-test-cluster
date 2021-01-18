#!/bin/bash

# Namespaces
NAMESPACE01="icap-adaptation"
NAMESPACE02="icap-administration"
NAMESPACE03="icap-ncfs"
NAMESPACE04="icap-rabbit-operator" 
NAMESPACE05="icap-central-monitoring"

# chart director
DIRECTORY="./charts/icap-infrastructure"

# Chart file path
ADAPTATION="./adaptation"
ADMINISTRATION="./administration"
NCFS="./ncfs"
RABBIT_OP="./rabbitmq-operator"
MONITORING=

# Deploy charts
(cd $DIRECTORY; helm install $RABBIT_OP -n $NAMESPACE04 --generate-name --set secrets=null)
echo ""
(cd $DIRECTORY; helm install $ADAPTATION -n $NAMESPACE01 --generate-name --set secrets=null)
echo ""
(cd $DIRECTORY; helm install $ADMINISTRATION -n $NAMESPACE02 --generate-name --set secrets=null)
echo ""
(cd $DIRECTORY; helm install $NCFS -n $NAMESPACE03 --generate-name --set secrets=null)
