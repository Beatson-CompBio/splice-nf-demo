process FASTQC {
  tag { "${meta.id}" }
  publishDir { params.outdir ? params.outdir + "/qc/fastqc" : "${projectDir}/results/qc/fastqc" }, mode: params.publish_dir_mode
  cpus 1
  memory '1 GB'
  time '2h'

  // Packaging options
  conda (params.packaging == 'conda' ? "${projectDir}/nextflow/environment/qc.yml" : null)
  container (params.packaging == 'apptainer' && params.fastqc_sif ? params.fastqc_sif : null)

  input:
    tuple val(meta), path(reads)

  output:
    tuple val(meta), path("*.html"), emit: html
    tuple val(meta), path("*.zip"),  emit: zip

  when:
    !params.skip_fastqc

  script:
  def extra = ''
  """
  fastqc --quiet --outdir . ${reads}
  """
}
