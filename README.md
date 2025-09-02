# splice-nf-demo

[![Module Tests](https://img.shields.io/endpoint?url=https://gist.github.com/siddharthjayaraman/99f7f05dbdeb549636f776a6867a448c/raw/test-badge.json)](https://github.com/Beatson-CompBio/splice-nf-demo/actions/workflows/nf-test.yml)

A minimal SPLICE-compliant Nextflow DSL2 workflow that runs FastQC then MultiQC.
Designed for TRE environments with no internet access, while still supporting
Conda and Apptainer for testing outside TRE.

## Quick start

Local test with synthetic reads, using Conda:

```bash
# Create a tiny synthetic dataset
bash tests/data/make_reads.sh tests/data/reads

# Run with Conda (installs fastqc 0.12.1 and multiqc 1.30)
nextflow run . -profile test,conda --reads "tests/data/reads/*.fastq.gz" --outdir results
```

Apptainer example, using local SIFs:

```bash
# Set your local container images
nextflow run . -profile test,apptainer \
  --reads "tests/data/reads/*.fastq.gz" \
  --fastqc_sif environment/containers/fastqc.sif \
  --multiqc_sif environment/containers/multiqc.sif \
  --outdir results
```

Samplesheet mode:

```bash
nextflow run . -profile test,conda \
  --input samplesheet.csv \
  --outdir results
```

The samplesheet must be CSV with a header and columns:
`sample_id,fastq_1,fastq_2,platform,center,batch,lane`
Only `sample_id` and `fastq_1` are required. `fastq_2` and `lane` are optional.
Files must be `*.fastq.gz`.

## Outputs
```
results/
  qc/
    fastqc/
      *.html
      *.zip
    multiqc/
      multiqc_report.html
      multiqc_data/
```

## Parameters
- `--input` CSV samplesheet
- `--reads` glob for quick mode without a samplesheet
- `--outdir` output directory, default `results`
- `--skip_fastqc` skip running FastQC
- `--skip_multiqc` skip running MultiQC
- `--multiqc_config` path to a MultiQC config YAML
- `--max_cpus`, `--max_memory`, `--max_time` resource caps
- `--fastqc_sif`, `--multiqc_sif` Apptainer SIF paths for offline use

See `nextflow_schema.json` for the complete schema.

## Notes
- No external downloads at run time in TRE. Use local SIFs or a prepopulated Conda cache.
- Methods description text is provided in `assets/methods_description_template.yml`.
- MultiQC title is set to "SPLICE FASTQ QC Report" via `assets/multiqc_config.yml`.
