#!/bin/bash

hpc=""
remote_files=""

usage="Usage: $0 -c <hpc> -r <remote_files>"

while getopts "hc:r:" opt; do
  case $opt in
  h)
    cat <<EOT
$usage
  -c  ssh host / alias of the HPC
  -r  remote files (space-separated, remote globs ok); may be followed by more words
  -h  show this help and exit
Runs: rsync -hazvP <hpc>:<file>... ./
EOT
    exit 0
    ;;
  c) hpc="$OPTARG" ;;
  r)
    remote_files="$OPTARG"
    # also take following words up to the next flag: -r a b -c hpc
    while [[ $OPTIND -le $# && "${!OPTIND}" != -* ]]; do
      remote_files+=" ${!OPTIND}"
      OPTIND=$((OPTIND + 1))
    done
    ;;
  *)
    echo "$usage" >&2
    exit 1
    ;;
  esac
done

shift $((OPTIND - 1))

if [[ -z "$hpc" || -z "$remote_files" ]]; then
  echo "Error: Missing required arguments." >&2
  echo "$usage" >&2
  exit 1
fi

# prefix each path with host: (unquoted split on purpose; remote globs still expand remotely)
srcs=()
for f in $remote_files; do srcs+=("${hpc}:${f}"); done

rsync -hazvP "${srcs[@]}" ./
