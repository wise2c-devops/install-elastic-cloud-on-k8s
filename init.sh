#! /bin/bash

set -e

path=`dirname $0`

ElasticCloudVersion=`cat ${path}/components.txt |grep "ElasticCloud" |awk '{print $3}'`
ElasticStackVersion=`cat ${path}/components.txt |grep "ElasticStack" |awk '{print $3}'`

curl -L -o ${path}/file/eck-origin.yaml https://download.elastic.co/downloads/eck/${ElasticCloudVersion}/all-in-one.yaml

cat ${path}/file/eck-origin.yaml |grep "image: docker.elastic.co/eck/" |awk -F":" '{print $2":"$3}' > ${path}/file/images-list.txt
echo "docker.elastic.co/elasticsearch/elasticsearch:${ElasticStackVersion}" >> ${path}/file/images-list.txt
echo "docker.elastic.co/kibana/kibana:${ElasticStackVersion}" >> ${path}/file/images-list.txt
echo "fluent/fluentd-kubernetes-daemonset:v1-debian-elasticsearch" >> ${path}/file/images-list.txt

echo 'Images list for Elastic Cloud:'
cat ${path}/file/images-list.txt

for file in $(cat ${path}/file/images-list.txt); do docker pull $file; done
echo 'Images pulled.'

docker save $(cat ${path}/file/images-list.txt) -o ${path}/file/elastic-cloud-images.tar
echo 'Images saved.'

curl -L -o ${path}/file/fluentd-origin.yaml https://raw.githubusercontent.com/fluent/fluentd-kubernetes-daemonset/master/fluentd-daemonset-elasticsearch-rbac.yaml
