[golang-grpc](../../../golang-grpc/) を管理するための [Subchart](https://v2.helm.sh/docs/developing_charts/#complex-charts-with-many-dependencies)

## 特徴

- gRPC の負荷分散を実現するため [Headless Service](https://kubernetes.io/ja/docs/concepts/services-networking/service/#headless-service) にしている
- autoscaling 確認済み
