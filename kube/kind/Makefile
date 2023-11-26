.PHONY: upgrade
upgrade:
	helm upgrade sample-service ./sample-service-helm --set service.type=NodePort --set service.nodePort=31234

.PHONY: init
init:
	# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	# kubectl wait --namespace ingress-nginx \
	# 	--for=condition=ready pod \
	# 	--selector=app.kubernetes.io/component=controller \
	# 	--timeout=90s

	kind load --name local-dev docker-image golang-bff:latest
	kind load --name local-dev docker-image sample-service:latest
	kind load --name local-dev docker-image my-nginx:latest
	kind load --name local-dev docker-image golang-grpc:latest
	helm install sample-service ./sample-service-helm --set service.type=NodePort --set service.nodePort=31234
	kubectl apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml
	# helm upgrade --install ingress-nginx ingress-nginx \
	# 	--repo https://kubernetes.github.io/ingress-nginx \
	# 	--namespace ingress-nginx --create-namespace

.PHONY: uninstall
uninstall:
	helm uninstall sample-service

.PHONY: install
install:
	helm install sample-service ./sample-service-helm --set service.type=NodePort --set service.nodePort=31234

linux:	# 調査用に建てた debian コンテナに入る。
	kubectl exec -it "$$(kubectl get po | grep debian | awk '{print $$1}')" /bin/bash
