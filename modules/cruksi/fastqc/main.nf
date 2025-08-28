process FASTQC {
  tag { "${meta.id}" }
  publishDir { params.outdir ? params.outdir + "/qc/fastqc" : "${projectDir}/results/qc/fastqc" }, mode: params.publish_dir_mode
  cpus 1
  memory '1 GB'
  time '2h'

  // Packaging options
  conda "${moduleDir}/environment.yml"
  container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
      'https://depot.galaxyproject.org/singularity/fastqc:0.12.1--hdfd78af_0' :
      'biocontainers/fastqc:0.12.1--hdfd78af_0' }"

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
