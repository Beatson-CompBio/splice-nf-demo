#!/usr/bin/env bash
set -Eeuo pipefail
# Helper to build SIFs from Docker sources for non-TRE testing
# Adjust image sources to your mirrors if needed.

# FastQC 0.12.1 from Biocontainers
apptainer build fastqc.sif docker://quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0

# MultiQC 1.30 from Biocontainers
apptainer build multiqc.sif docker://quay.io/biocontainers/multiqc:1.30--pyhdfd78af_0
