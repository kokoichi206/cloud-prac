``` sh
node index.js


docker build . -t golang-bff:latest

docker images | grep sample
sample-service                                                              latest      2eaa9538d659   13 seconds ago   856MB


docker run -p 33333:8080 -it golang-bff


```
