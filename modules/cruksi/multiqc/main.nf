process MULTIQC {
  tag { "multiqc" }
  publishDir { params.outdir ? params.outdir + "/qc/multiqc" : "${projectDir}/results/qc/multiqc" }, mode: params.publish_dir_mode
  cpus 1
  memory '1 GB'
  time '2h'

  conda (params.packaging == 'conda' ? "${projectDir}/nextflow/environment/qc.yml" : null)
  container (params.packaging == 'apptainer' && params.multiqc_sif ? params.multiqc_sif : null)

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
