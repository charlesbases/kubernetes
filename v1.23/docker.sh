#!/usr/bin/env bash

set -e

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
}

main

if [[ "$1" = "-o" ]]; then
  save
fi
