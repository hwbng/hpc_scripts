#!/bin/bash

hpc=""
remote_dir=""
extras=""

usage="Usage: $0 -c <hpc> -r <remote_dir> [-e <comma-separated extra files, e.g. CHGCAR,WAVECAR,vasprun.xml>]. Put <remote_dir> in quotes to use wildcards."

while getopts "hc:r:e:" opt; do
  case $opt in
  h)
    cat <<EOT
$usage
  -c  ssh host / alias of the HPC
  -r  remote directory to fetch from
  -e  extra files to include (comma-separated name prefixes, matched as NAME*)
  -h  show this help and exit
Runs: rsync -hazvP into ./ including only dirs plus these patterns:
  *OUTCAR* *OSZICAR* *XDATCAR* *INCAR* *POSCAR* *CONTCAR* *KPOINTS*
  *.json* *.yaml* slurm*  (+ extras), excluding everything else
EOT
    exit 0
    ;;
  c) hpc="$OPTARG" ;;
  r) remote_dir="$OPTARG" ;;
  e) extras="$OPTARG" ;;
  *)
    echo "$usage" >&2
    exit 1
    ;;
  esac
done

shift $((OPTIND - 1))

if [[ -z "$hpc" || -z "$remote_dir" ]]; then
  echo "Error: Missing required arguments." >&2
  echo "$usage" >&2
  exit 1
fi

extra_args=()
if [[ -n "$extras" ]]; then
  IFS=',' read -ra names <<<"$extras"
  for n in "${names[@]}"; do
    extra_args+=("--include=*${n}*")
  done
fi

rsync -hazvP --include='*/' \
  --include='*OUTCAR*' \
  --include='*OSZICAR*' \
  --include='*XDATCAR*' \
  --include='*INCAR*' \
  --include='*POSCAR*' \
  --include='*CONTCAR*' \
  --include='*KPOINTS*' \
  --include='*.json*' \
  --include='*.yaml*' \
  --include='slurm*' \
  "${extra_args[@]}" \
  --exclude='*' \
  "${hpc}:${remote_dir}" ./
