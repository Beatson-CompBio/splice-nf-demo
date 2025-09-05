# splice-nf-demo

[![nf-test](https://github.com/Beatson-CompBio/splice-nf-demo/actions/workflows/nf-test.yml/badge.svg)](https://github.com/Beatson-CompBio/splice-nf-demo/actions/workflows/nf-test.yml)

A minimal **SPLICE‑compliant** Nextflow DSL2 workflow that runs **FastQC → MultiQC**. This README shows how to run the *demo pipeline* with **Singularity** either:

1. **Without a samplesheet** — just point at a folder of `*.fastq.gz` files using a glob.
2. **With a CSV samplesheet** — the FASTQs can be local *or* public HTTP(S)/S3 URLs (example provided below).
3. **With the SPLICE CRUKSI HPC profile** — designed for the SPLICE data platform with standardized directory structure and job management.

> This guide focuses on the `singularity` profile for general use and the `splice_cruksi_hpc` profile for the SPLICE data platform. If you are running in an offline TRE, local `.sif` images can be used. If you have internet access, Singularity can pull from Docker registries on the fly.

---

## Prerequisites

* **Nextflow** (25.04+ recommended)
* **Singularity** installed
* For remote FASTQs: outbound HTTP(S) access
* For offline TREs: local `.sif` images for FastQC and MultiQC
* For SPLICE platform: standardized directory structure with job IDs

---

## Option A — Run with a glob (no samplesheet)

Use this when all your reads sit in one folder. Paired and single‑end files are both supported as long as they end with `.fastq.gz`.

```bash
# Example: run with local FASTQs using the Singularity profile
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

## Option C — Run with SPLICE CRUKSI HPC Profile

The `splice_cruksi_hpc` profile is designed for the SPLICE data platform with a standardized directory structure and automated job management on SLURM HPC systems.

### Directory Structure

The profile expects this standardized directory structure:

```
{job_id}/                           # UUID job directory
├── input_data/
│   ├── containers/                 # Singularity cache directory
│   │   ├── depot.galaxyproject.org-singularity-fastqc-0.12.1--hdfd78af_0.img
│   │   └── depot.galaxyproject.org-singularity-multiqc-1.30--pyhdfd78af_0.img
│   ├── data/                       # Input data directory
│   │   ├── sample1_R1.fastq.gz
│   │   ├── sample1_R2.fastq.gz
│   │   └── samplesheet.csv (optional)
│   └── nextflow/                   # Pipeline directory
│       ├── main.nf
│       ├── nextflow.config
│       └── ...
└── output_data/                    # Execution directory (run from here)
```

### Usage

Run the pipeline from the `output_data` directory:

```bash
# Basic usage with glob pattern (recommended)
nextflow run ../input_data/nextflow \
  -profile splice_cruksi_hpc \
  --job_id ae3a9e47-63cf-44ce-8405-10f67672ba2d \
  --short_job_id a123

# With custom log location
nextflow -log ~/ae3a9e47-63cf-44ce-8405-10f67672ba2d.nextflow.log run ../input_data/nextflow \
  -profile splice_cruksi_hpc \
  --job_id ae3a9e47-63cf-44ce-8405-10f67672ba2d \
  --short_job_id a123

# With explicit reads pattern
nextflow run ../input_data/nextflow \
  -profile splice_cruksi_hpc \
  --job_id ae3a9e47-63cf-44ce-8405-10f67672ba2d \
  --short_job_id a123 \
  --reads "../input_data/data/*.fastq.gz"

# With samplesheet
nextflow run ../input_data/nextflow \
  -profile splice_cruksi_hpc \
  --job_id ae3a9e47-63cf-44ce-8405-10f67672ba2d \
  --short_job_id a123 \
  --input "../input_data/data/samplesheet.csv"
```

### SPLICE Profile Features

* **Automated paths**: Uses standardized data platform directory structure
* **SLURM integration**: Submits jobs to the 'compute' partition with job name prefixes
* **Container management**: Uses pre-cached Singularity images from `../input_data/containers/`
* **Job organization**: Creates output directories with job_id prefix
* **Smart defaults**: Automatically detects samplesheet or falls back to glob pattern

### SPLICE Profile Parameters

* `--job_id`: UUID job identifier (used for output directory naming)
* `--short_job_id`: Short identifier used as prefix for SLURM job names (e.g., `a123_FASTQC`)

---

## Outputs

### Standard Profiles
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

### SPLICE Profile
```
output_data/
  {job_id}_output/
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
* `--multiqc_config` : Path to a MultiQC config YAML (optional)
* `--max_cpus`, `--max_memory`, `--max_time` : Resource caps
* `--fastqc_sif`, `--multiqc_sif` : Paths to local SIFs for offline runs

### SPLICE Platform Parameters
* `--job_id` : UUID job identifier for output directory naming
* `--short_job_id` : Short job identifier for SLURM job name prefixes

See `nextflow_schema.json` for the full parameter schema.

---

## Profiles

* `singularity` : General use with Singularity containers
* `apptainer` : General use with Apptainer containers  
* `conda` : Use Conda environments instead of containers
* `docker` : Use Docker containers
* `test` : Run with test data and minimal resources
* `splice_cruksi_hpc` : SPLICE CRUKSI HPC data platform with standardized paths and SLURM integration

---

## Tips

* **Exactly match the samplesheet headers** — they are case‑sensitive.
* In glob mode, the samplesheet is ignored.
* Files must be `*.fastq.gz` (local paths or direct HTTP(S) links).
* MultiQC title and methods text can be customised via the files in `assets/`.
* For SPLICE platform: ensure the standardized directory structure is in place before running.
* SLURM jobs will be named with the pattern `{short_job_id}_{process_name}` (e.g., `a123_FASTQC`).
