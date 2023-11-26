.PHONY: build
build:
	docker build . -t golang-grpc:latest
	kind load --name local-dev docker-image golang-grpc:latest
