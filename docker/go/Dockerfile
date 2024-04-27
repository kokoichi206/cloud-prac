# syntax=docker/dockerfile:1

# 1. build
FROM golang:1.22 AS build

WORKDIR /app

COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY *.go ./

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -trimpath -o ./api ./app

# 2. deploy
FROM gcr.io/distroless/base-debian10
WORKDIR /
COPY --from=build /api /api

EXPOSE 8080
USER nonroot:nonroot

ENTRYPOINT ["/api"]
