#!/bin/bash
set -e

path=`dirname $0`

MyImageRepositoryIP=`cat ${path}/components.txt |grep "Harbor Address" |awk '{print $3}'`
MyImageRepositoryProject=library
ElasticCloudVersion=`cat ${path}/components.txt |grep "ElasticCloud" |awk '{print $3}'`
ElasticStackVersion=`cat ${path}/components.txt |grep "ElasticStack" |awk '{print $3}'`

######### Push images #########
docker load -i file/elastic-cloud-images.tar

for file in $(cat file/images-list.txt); do docker tag $file $MyImageRepositoryIP/$MyImageRepositoryProject/${file##*/}; done

echo 'Images taged.'

for file in $(cat file/images-list.txt); do docker push $MyImageRepositoryIP/$MyImageRepositoryProject/${file##*/}; done

echo 'Images pushed.'

######### Update deploy yaml files #########
cd file
rm -f eck.yaml
cp eck-origin.yaml eck.yaml
sed -i "s,docker.elastic.co/eck,$MyImageRepositoryIP\/$MyImageRepositoryProject,g" eck.yaml

rm -f elasticsearch.yaml
cp elasticsearch-origin.yaml elasticsearch.yaml
sed -i "s,{{ registry_endpoint }}/{{ registry_project }},$MyImageRepositoryIP\/$MyImageRepositoryProject,g" elasticsearch.yaml
sed -i "s,{{ elastic_stack_version }},$ElasticStackVersion,g" elasticsearch.yaml

rm -f kibana.yaml
cp kibana-origin.yaml kibana.yaml
sed -i "s,{{ registry_endpoint }}/{{ registry_project }},$MyImageRepositoryIP\/$MyImageRepositoryProject,g" kibana.yaml
sed -i "s,{{ elastic_stack_version }},$ElasticStackVersion,g" kibana.yaml

rm -f fluentd.yaml
cp fluentd-origin.yaml fluentd.yaml
sed -i "s,fluent/fluentd-kubernetes-daemonset,$MyImageRepositoryIP\/$MyImageRepositoryProject,g" fluentd.yaml

# Elastic Operator deploy
kubectl create -f  ./eck.yaml

# Wait for CRDs to be ready.
printf "Waiting for ElasticCloud Operator to register custom resource definitions..."

crd_apmservers_status="false"
until [ "$crd_apmservers_status" = "True" ]; do sleep 1; printf "."; crd_apmservers_status=`kubectl get customresourcedefinitions apmservers.apm.k8s.elastic.co -o jsonpath='{.status.conditions[1].status}' 2>&1`; done

crd_elasticsearches_status="false"
until [ "$crd_elasticsearches_status" = "True" ]; do sleep 1; printf "."; crd_elasticsearches_status=`kubectl get customresourcedefinitions elasticsearches.elasticsearch.k8s.elastic.co -o jsonpath='{.status.conditions[1].status}' 2>&1`; done

crd_kibanas_status="false"
until [ "$crd_kibanas_status" = "True" ]; do sleep 1; printf "."; crd_kibanas_status=`kubectl get customresourcedefinitions kibanas.kibana.k8s.elastic.co -o jsonpath='{.status.conditions[1].status}' 2>&1`; done

until kubectl get apmservers.apm.k8s.elastic.co > /dev/null 2>&1; do sleep 1; printf "."; done
until kubectl get elasticsearches.elasticsearch.k8s.elastic.co > /dev/null 2>&1; do sleep 1; printf "."; done
until kubectl get kibanas.kibana.k8s.elastic.co > /dev/null 2>&1; do sleep 1; printf "."; done

echo 'Elastic Cloud CRD is ready!'

kubectl apply -f ./elasticsearch.yaml
kubectl apply -f ./kibana.yaml
kubectl apply -f ../template/elasticsearch-service.yaml
kubectl apply -f ../template/kibana-service.yaml

echo 'Elastic Cloud has been deployed.'

# Deploy Fluentd
set +e
estatus="false"
until [ "$estatus" = "Secret" ]; do sleep 1; printf "."; estatus=`kubectl get secret quickstart-es-elastic-user -o jsonpath='{.kind}'`; done
PASSWORD=$(kubectl get secret quickstart-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode)
sed -i "s,changeme,${PASSWORD},g" fluentd.yaml
kubectl apply -f ./fluentd.yaml
