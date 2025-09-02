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
      'quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0' }"

  input:
    tuple val(meta), path(reads)

  output:
    tuple val(meta), path("*.html"), emit: html
    tuple val(meta), path("*.zip"),  emit: zip
    path "versions.yml"            , emit: versions

  when:
    !params.skip_fastqc

  script:
  def args = task.ext.args ?: ''
  def prefix = task.ext.prefix ?: "${meta.id}"
  """
  fastqc --quiet --outdir . ${reads}

  cat <<-END_VERSIONS > versions.yml
  "${task.process}":
      fastqc: \$(fastqc --version | sed -e "s/FastQC v//g")
  END_VERSIONS
  """

  stub:
  def prefix = task.ext.prefix ?: "${meta.id}"
  """
  touch ${prefix}.html
  touch ${prefix}.zip

  cat <<-END_VERSIONS > versions.yml
  "${task.process}":
      fastqc: \$(fastqc --version | sed -e "s/FastQC v//g")
  END_VERSIONS
  """
}
