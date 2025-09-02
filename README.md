# splice-nf-demo

[![nf-test](https://github.com/Beatson-CompBio/splice-nf-demo/actions/workflows/nf-test.yml/badge.svg)](https://github.com/Beatson-CompBio/splice-nf-demo/actions/workflows/nf-test.yml)

A minimal **SPLICE‑compliant** Nextflow DSL2 workflow that runs **FastQC → MultiQC**. This README shows how to run the *demo pipeline* with **Singularity** either:

1. **Without a samplesheet** — just point at a folder of `*.fastq.gz` files using a glob.
2. **With a CSV samplesheet** — the FASTQs can be local *or* public HTTP(S)/S3 URLs (example provided below).

> This guide focuses on the `singularity` profile. If you are running in an offline TRE, local `.sif` images can be used. If you have internet access, Singularity can pull from Docker registries on the fly.

---

## Prerequisites

* **Nextflow** (25.04+ recommended)
* **Singularity** installed
* For remote FASTQs: outbound HTTP(S) access
* For offline TREs: local `.sif` images for FastQC and MultiQC

---

## Option A — Run with a glob (no samplesheet)

Use this when all your reads sit in one folder. Paired and single‑end files are both supported as long as they end with `.fastq.gz`.

```bash
# Example: run with local FASTQs using the Singularity/Apptainer profile
nextflow run . \
  -profile singularity \
  --reads "/path/to/reads/*.fastq.gz" \
  --outdir results
```

---

## Option B — Run with a CSV samplesheet (supports HTTP/HTTPS)

When using a samplesheet, **column headers are mandatory** and must match exactly. Only `sample_id` and `fastq_1` are required; `fastq_2` is optional for single‑end data.

**Required headers:**

```
sample_id,fastq_1,fastq_2
```

**Example (paired‑end, remote URLs):**

```
sample_id,fastq_1,fastq_2
SAMPLE1_PE,https://raw.githubusercontent.com/nf-core/test-datasets/viralrecon/illumina/amplicon/sample1_R1.fastq.gz,https://raw.githubusercontent.com/nf-core/test-datasets/viralrecon/illumina/amplicon/sample1_R2.fastq.gz
SAMPLE2_PE,https://raw.githubusercontent.com/nf-core/test-datasets/viralrecon/illumina/amplicon/sample2_R1.fastq.gz,https://raw.githubusercontent.com/nf-core/test-datasets/viralrecon/illumina/amplicon/sample2_R2.fastq.gz
```

Save the file as `samplesheet.csv`, then run:

```bash
nextflow run . \
  -profile singularity \
  --input samplesheet.csv \
  --outdir results
```

> Notes
>
> * Remote URLs must be directly downloadable (`.fastq.gz`).
> * Mixing remote and local paths in the same sheet is supported.
> * If a row is single‑end, leave `fastq_2` empty (e.g. `sample_se,/path/R1.fastq.gz,`).

---

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

---

## Key parameters

* `--input` : CSV samplesheet path (with headers `sample_id,fastq_1,fastq_2`)
* `--reads` : Glob for quick mode without a samplesheet (e.g., `"/path/*.fastq.gz"`)
* `--outdir` : Output directory (default: `results`)
* `--skip_fastqc` : Skip FastQC
* `--skip_multiqc` : Skip MultiQC
* `--multiqc_config` : Path to a MultiQC config YAML (optional)
* `--max_cpus`, `--max_memory`, `--max_time` : Resource caps
* `--fastqc_sif`, `--multiqc_sif` : Paths to local SIFs for offline runs

See `nextflow_schema.json` for the full parameter schema.

---

## Tips

* **Exactly match the samplesheet headers** — they are case‑sensitive.
* In glob mode, the samplesheet is ignored.
* Files must be `*.fastq.gz` (local paths or direct HTTP(S) links).
* MultiQC title and methods text can be customised via the files in `assets/`.

