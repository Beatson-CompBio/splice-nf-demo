process MULTIQC {
  tag { "multiqc" }
  publishDir { params.outdir ? params.outdir + "/qc/multiqc" : "${projectDir}/results/qc/multiqc" }, mode: params.publish_dir_mode
  cpus 1
  memory '1 GB'
  time '2h'

  conda "${moduleDir}/environment.yml"
  container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
      'https://depot.galaxyproject.org/singularity/multiqc:1.30--pyhdfd78af_0' :
      'biocontainers/multiqc:1.30--pyhdfd78af_0' }"

  input:
    // Any value to act as a barrier to FastQC completion
    val(done_flag)

  output:
    path "multiqc_report.html", emit: report
    path "multiqc_data",        emit: data

  when:
    !params.skip_multiqc

  script:
  def cfg = params.multiqc_config ? "-c ${params.multiqc_config}" : "-c ${projectDir}/assets/multiqc_config.yml"
  def src = params.outdir ? params.outdir + "/qc/fastqc" : "${projectDir}/results/qc/fastqc"
  """
  multiqc --force --outdir . --filename multiqc_report.html ${cfg} ${src}
  """
}
