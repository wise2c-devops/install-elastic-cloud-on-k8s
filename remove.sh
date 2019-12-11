#!/bin/bash
kubectl delete -f file/fluentd.yaml
kubectl delete -f template/kibana-service.yaml
kubectl delete -f template/elasticsearch-service.yaml
kubectl delete kibana quickstart
kubectl delete elasticsearch quickstart
kubectl delete -f file/kibana.yaml
kubectl delete -f file/elasticsearch.yaml
kubectl delete -f file/eck.yaml
