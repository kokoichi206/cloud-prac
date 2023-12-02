.PHONY: build
build:
	docker build . -t my-nginx:latest
	kind load --name local-dev docker-image my-nginx:latest
