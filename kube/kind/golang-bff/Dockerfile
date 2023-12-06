# syntax=docker/dockerfile:1

# 1. build
FROM golang:1.21 AS build

WORKDIR /app

COPY go.mod ./
COPY go.sum ./

COPY *.go ./

RUN CGO_ENABLED=0 GOOS=linux go build -o /api

# 2. deploy
# nonroot tag は、初手で USER nonroot とするのと一緒？
FROM gcr.io/distroless/static:debug-nonroot
# WORKDIR の設定より前に USER を設定すると、設定されたユーザーでディレクトリが作成される。
# /app-workdir $ ls -ld .
# drwxr-xr-x    1 nonroot  nonroot       4096 Dec  6 15:53 .
WORKDIR /app-workdir

# ここは chown をつけないと、nonroot で実行しても root でコピーされる。
COPY --chown=nonroot:nonroot --from=build /api /app-workdir/api

EXPOSE 8080

# 最終系。
# /app-workdir $ ls -la
# total 18188
# drwxr-xr-x    1 nonroot  nonroot       4096 Dec  6 15:58 .
# drwxr-xr-x    1 root     root          4096 Dec  6 15:58 ..
# -rwxr-xr-x    1 nonroot  nonroot   18609217 Dec  6 15:56 api
# drwxr-xr-x    2 nonroot  nonroot       4096 Dec  6 15:58 tmp

ENTRYPOINT ["/app-workdir/api"]
