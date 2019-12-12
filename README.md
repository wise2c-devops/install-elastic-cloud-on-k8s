# Install ECK (Elastic Cloud on Kubernetes) offline

**1. Fetch installation packages and images**

Execute the command as below on the server which can access internet.

```
bash init.sh
```

**2. Install ECK (Elastic Cloud on Kubernetes) offline**

(1) Copy the whole folder "install-elastic-cloud-on-k8s" to a K8s node with kubectl command.

(2) Modify the harbor address in the file "components.txt"

(3) Execute below commands:

```
cd install-elastic-cloud-on-k8s
bash deploy.sh
```

If you want to change the nodeport for 2 services (Elasticsearch, Kibana), please update the files in template folder.

**3. Remove Elastic Cloud on Kubernetes**

Execute the command as below on the K8s node:

```
bash remove.sh
```
