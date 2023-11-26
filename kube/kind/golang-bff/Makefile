.PHONY: build
build:
	docker build . -t golang-bff:latest
	kind load --name local-dev docker-image golang-bff:latest
