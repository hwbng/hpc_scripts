#!/bin/bash

hpc=""
remote_dir=""
upload_files=""

usage="Usage: $0 -c <hpc> -f <input files> -r <remote_dir>"

while getopts "hc:f:r:" opt; do
  case $opt in
  h)
    cat <<EOT
$usage
  -c  ssh host / alias of the HPC
  -f  local files to upload (space-separated); may be followed by more words
  -r  remote destination directory
  -h  show this help and exit
Runs: rsync -hazvP <files> <hpc>:<remote_dir>
EOT
    exit 0
    ;;
  c) hpc="$OPTARG" ;;
  f)
    upload_files="$OPTARG"
    # also take following words up to the next flag: -f INCAR OUTCAR -r dir
    while [[ $OPTIND -le $# && "${!OPTIND}" != -* ]]; do
      upload_files+=" ${!OPTIND}"
      OPTIND=$((OPTIND + 1))
    done
    ;;
  r) remote_dir="$OPTARG" ;;
  *)
    echo "$usage" >&2
    exit 1
    ;;
  esac
done

shift $((OPTIND - 1))

if [[ -z "$hpc" || -z "$remote_dir" || -z "$upload_files" ]]; then
  echo "Error: Missing required arguments." >&2
  echo "$usage" >&2
  exit 1
fi

rsync -hazvP ${upload_files} ${hpc}:${remote_dir}
