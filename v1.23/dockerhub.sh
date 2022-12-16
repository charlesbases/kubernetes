#!/usr/bin/env bash

set -e

images="images.txt"
repository="192.168.10.10:12345/kubernetes"

backfile="images.bak.txt"

repo() {
  if [[ ! -f "$backfile" ]]; then
    cat >> $backfile << EOF
$1
EOF
  return
  fi

  if [[ -z `cat $backfile | grep $1` ]]; then
    cat >> $backfile << EOF
$1
EOF
  fi
}

main() {
  cat $images | while read image; do
    if [[ ! $image == \#* ]]; then
      echo -e "\033[32mdocker pull $image ...\033[0m"

      local tag=${image##*:}
      local image=${image%:*}
      local private=$repository/${image##*/}
      
      if [[ $(docker images | grep "$image" | grep "$tag") ]]; then
        continue
      fi

      if [[ $(docker images | grep "$private" | grep "$tag") ]]; then
        continue
      fi

      # docker pull
      docker pull $image:$tag

      # docker tag
      docker tag $image:$tag $private:$tag

      repo "$private:$tag"
    fi
  done
}

main

# docker-push
read -sp "镜像推送(Y/N): " isPush
if [[ $isPush =~ ^[yY]+$ ]]; then
  cat $backfile |  while read image; do
    docker push $image
  done
fi

# docker-clean
read -sp "镜像清理(Y/N): " isClean
if [[ $isClean =~ ^[yY]+$ ]]; then
  cat $images |  while read image; do
    if [[ ! $image == \#* ]]; then
      docker push $image
    fi
  done
fi
