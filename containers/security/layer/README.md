``` sh
docker build . -t my-secret:latest
docker save my-secret > secret.tar
mkdir secret
cd secret
tar -xf ../secret.tar
```
