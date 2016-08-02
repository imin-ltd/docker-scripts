#!/usr/bin/env bash

set -e -o pipefail

if [[ $# != 1 ]]
then
  printf 'Usage: %s <registry-host>\n' "${BASH_SOURCE[0]}"
  exit 1
fi

readonly registry=$1

readonly repos=$(set -o pipefail; docker images | grep $registry | awk '{ print $1 }' | awk '!x[$0]++')

[[ -z $repos ]] && { printf 'No candidates found for image cleanup from registry: %s\n' $registry; exit 0; }

printf 'Found the following candidates for image cleanup from registry %s:\n' $registry; printf '%s\n' $repos

for repo in $repos
do
  images=($(docker images -q $repo | awk '!x[$0]++'))
  if (( ${#images[*]} > 1 ))
  then
    printf 'Found %s images for %s, cleaning up all but most recent\n' ${#images[*]} $repo
#    printf 'Dry run removing %s\n' ${images[@]:1}
    docker rmi ${images[@]:1}
  else
    printf 'Found 1 image for %s, no image cleanup required\n' $repo
  fi
done
