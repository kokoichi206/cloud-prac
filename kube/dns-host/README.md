``` sh
kind create cluster --name dns-host-test
helm create dns-test

helm install dns-test ./dns-test

❯ kubectl get po
NAME                       READY   STATUS              RESTARTS   AGE
dns-test-b5574b58d-s7ktf   0/1     ContainerCreating   0          5s


kubectl apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml


❯ kubectl get po
NAME                       READY   STATUS              RESTARTS   AGE
dns-test-b5574b58d-s7ktf   1/1     Running             0          3m52s
dnsutils                   0/1     ContainerCreating   0          11s

❯ kubectl get services
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
dns-test     ClusterIP   10.96.227.223   <none>        80/TCP    5m22s
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP   7m19s

❯ kubectl exec dnsutils -- nslookup dns-test
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   dns-test.default.svc.cluster.local
Address: 10.96.227.223


kubectl exec -it dnsutils /bin/bash
```
