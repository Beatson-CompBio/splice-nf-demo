#!/usr/bin/env bash
set -Eeuo pipefail
outdir=${1:-tests/data/reads}
mkdir -p "$outdir"
mkfq() {
  local f=$1; local n=${2:-50}
  {
    for i in $(seq 1 $n); do
      echo "@SEQ${i}"
      echo "ACGTACGTACGTACGTACGT"
      echo "+"
      echo "FFFFFFFFFFFFFFFFFFFF"
    done
  } | gzip -c > "$f"
}
mkfq "$outdir/sampleA_R1.fastq.gz" 50
mkfq "$outdir/sampleA_R2.fastq.gz" 50
mkfq "$outdir/sampleB_R1.fastq.gz" 30
