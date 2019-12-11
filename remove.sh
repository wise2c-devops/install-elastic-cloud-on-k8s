#!/bin/bash
kubectl delete -f fluentd.yml
kubectl delete -f kibana-service.yml
kubectl delete -f elasticsearch-service.yml
kubectl delete kibana quickstart
kubectl delete elasticsearch quickstart
kubectl delete -f kibana.yml
kubectl delete -f elasticsearch.yml
kubectl delete -f eck.yml
