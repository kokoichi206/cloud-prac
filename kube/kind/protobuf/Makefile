.PHONY: generate

generate:
	protoc --go_out=./gen --go-grpc_out=./gen ./*.proto
	cd ./gen/go/protobuf && go mod tidy
