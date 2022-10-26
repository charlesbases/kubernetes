#!/usr/bin/env bash

set -e

images=(
# k8s.gcr.io
"k8s.gcr.io/kube-proxy:v1.23.9"
"k8s.gcr.io/kube-apiserver:v1.23.9"
"k8s.gcr.io/kube-scheduler:v1.23.9"
"k8s.gcr.io/kube-controller-manager:v1.23.9"
"k8s.gcr.io/pause:3.6"
"k8s.gcr.io/etcd:3.5.1-0"
"k8s.gcr.io/coredns/coredns:v1.8.6"
"k8s.gcr.io/metrics-server/metrics-server:v0.6.1"
# ingress-nginx
"registry.k8s.io/ingress-nginx/controller:v1.3.0"
"registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.1.1"
# kubesphere
"kubesphere/ks-installer:v3.3.0"
# calico
"docker.io/calico/cni:v3.23.2"
"docker.io/calico/node:v3.23.2"
"docker.io/calico/kube-controllers:v3.23.2"
)

remotes=(
"root@192.168.1.10 /root"
"root@192.168.1.11 /root"
"root@192.168.1.12 /root"
"root@192.168.1.13 /root"
)

repo="k8s.io"

total_images=${#images[@]}
total_remotes=${#remotes[@]}

# 镜像拉取
dockerpull() {
  for (( i = 0; i < $total_images; i++ )); do
    local image=${images[i]}

    echo -e "\033[32m[$[$i+1]/$total_images] docker pull $image ...\033[0m"
    docker pull $image
  done
}

# 镜像打包
dockersave() {
  for (( i = 0; i < $total_images; i++ )); do
    local image=${images[i]}
    local s1=${image##*/}
    local filename=${s1%:*}
    local dir=${image%%/*}

    mkdir -p $repo/$dir
    echo -e "\033[34m[$[$i+1]/$total_images] docker save $image ...\033[0m"
    docker save -o "$repo/$dir/$filename.tar" $image
  done

 cat > $repo/load.sh << "EOF"
#!/usr/bin/env bash
set -e
for a in $(ls); do
  if [[ -d "$a" ]]; then
    for file in $(ls $a | grep ".tar"); do
      image=$a/$file
      echo -e "\033[33mdocker load $image ...\033[0m"
      docker load -i $image
      echo
    done
  fi
done
EOF
  chmod +x $repo/load.sh
}

# 通过 scp 将镜像拷贝至其他服务器
dockerload() {
  if [[ ! -d "$repo" ]]; then
    echo "$repo: no such directory"
  fi

  for (( i = 0; i < $total_remotes; i++ )); do
    local row=(${remotes[i]})
    local remote=${row[0]}
    local remote_repo=${row[1]}

    echo -e "\033[35m[$[$i+1]/$total_remotes] $remote:$remote_repo/$repo\033[0m"

    ssh $remote "rm -rf $remote_repo/$repo"

    scp -C $repo $remote:$remote_repo/$repo

    ssh $remote "cd $remote_repo/$repo && source load.sh"
  done
}

if [[ "$1" = "pull" ]]; then
  dockerpull
  exit
fi

if [[ "$1" == "save" ]]; then
  dockersave
  exit
fi

if [[ "$1" == "load" ]]; then
  dockerload
  exit
fi

echo """\
usage:

  ./docker.sh <command>

the commands are:

  pull    docker pull with images
  save    docker save with images
  load    scp images to remotes and docker load them
"""
