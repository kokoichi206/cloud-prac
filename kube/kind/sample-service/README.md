``` sh
node index.js


docker build . -t sample-service

docker images | grep sample
sample-service                                                              latest      2eaa9538d659   13 seconds ago   856MB


docker run -p 23232:8080 -it sample-service


```
