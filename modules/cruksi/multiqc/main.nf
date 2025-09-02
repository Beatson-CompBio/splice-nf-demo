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
    path(multiqc_files, stageAs: "?/*")
    path(multiqc_config, stageAs: "multiqc_config.yml")

  output:
    path "multiqc_report.html", emit: report
    path "multiqc_report_data",        emit: data

  when:
    !params.skip_multiqc

  script:
  def config_opt = multiqc_config.name != 'OPTIONAL_FILE' ? "--config ${multiqc_config}" : ''
  """
  multiqc \\
    --force \\
    --outdir . \\
    --filename multiqc_report.html \\
    ${config_opt} \\
    .
  """
}
