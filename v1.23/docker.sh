#!/usr/bin/env bash

set -e

# images
#   - k8s.gcr.io
#       k8s.gcr.io/kube-proxy:v1.23.9
#       k8s.gcr.io/kube-apiserver:v1.23.9
#       k8s.gcr.io/kube-scheduler:v1.23.9
#       k8s.gcr.io/kube-controller-manager:v1.23.9
#       k8s.gcr.io/pause:3.6
#       k8s.gcr.io/etcd:3.5.1-0
#       k8s.gcr.io/coredns/coredns:v1.8.6
#       k8s.gcr.io/metrics-server/metrics-server:v0.6.1
#   - calico
#       docker.io/calico/cni:v3.23.2
#       docker.io/calico/node:v3.23.2
#       docker.io/calico/kube-controllers:v3.23.2
#   - ingress
#       quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.30.0

repo="k8s.io"
images="images.txt"

main() {
  cat $images | while read image; do
    if [[ ! $image == \#* ]]; then

      echo -e "\033[32mdocker pull $image ...\033[0m"
      docker pull $image
    fi
  done
}

save() {
  cat $images | while read image; do
    if [[ ! $image == \#* ]]; then

      local s1=${image##*/}
      local filename=${s1%:*}
      local dir=${image%%/*}
      if [[ ${#dir} -eq ${#image} ]]; then
        dir="others"
      fi

      mkdir -p $repo/$dir
      echo -e "\033[34mdocker save $image ...\033[0m"

      docker save -o "$repo/$dir/$filename.tar" $image
    fi
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

main

if [[ "$1" = "-o" ]]; then
  save
fi
