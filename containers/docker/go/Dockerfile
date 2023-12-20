# syntax=docker/dockerfile:1

# 1. build
FROM golang:1.21 AS build

WORKDIR /app

COPY go.mod ./
COPY go.sum ./

COPY *.go ./

RUN CGO_ENABLED=0 GOOS=linux go build -o /api

# 2. deploy
FROM gcr.io/distroless/static
WORKDIR /
COPY --from=build /api /api

EXPOSE 8080
USER nonroot:nonroot

ENTRYPOINT ["/api"]
