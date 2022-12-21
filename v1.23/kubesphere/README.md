# Kubesphere

[v3.3.0](https://github.com/kubesphere/ks-installer/tree/v3.3.0)

## 安装前提

- ##### 硬件要求

  ```text
  CPU > 1 Core，Memory > 2 G
  ```

- ##### 配置默认存储类型

  ```shell
  # 查看存储类型
  kubectl get storageclass
  
  # 设置默认存储类型
  kubectl patch storageclass [storageclass-name] -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
  ```

## 1. 安装

```shell
# 联网安装
kubectl apply -f https://github.com/kubesphere/ks-installer/releases/download/v3.3.1/kubesphere-installer.yaml
kubectl apply -f https://github.com/kubesphere/ks-installer/releases/download/v3.3.1/cluster-configuration.yaml
```

```shell
# 本地安装
kubectl apply -f kubesphere-installer.yaml
kubectl apply -f cluster-configuration.yaml
```

## 2. 检查安装日志

```shell
kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l 'app in (ks-install, ks-installer)' -o jsonpath='{.items[0].metadata.name}') -f
```

## 3. 查看运行情况

```shell
kubectl get svc/ks-console -n kubesphere-system
```
