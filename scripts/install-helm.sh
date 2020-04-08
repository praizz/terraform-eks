#!/bin/sh

# https://github.com/helm/helm/issues/5100
kubectl get serviceaccount -n kube-system tiller
kubectl get clusterrole -n kube-system cluster-admin
kubectl create clusterrolebinding tiller-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init 
# before kubectl patch, need to wait 10 seconds until tiller-deploy deployment is complete
#sleep 10
#kubectl --namespace kube-system patch deploy tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
