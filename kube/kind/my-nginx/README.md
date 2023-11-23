``` sh
node index.js


docker build . -t my-nginx:latest

kind load --name local-dev docker-image my-nginx:latest



docker run -p 41414:15555 -it my-nginx:latest

```
