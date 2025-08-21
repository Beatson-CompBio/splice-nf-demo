nextflow.enable.dsl=2

include { INGEST_SAMPLESHEET } from '../subworkflows/cruksi/ingest/main'
include { FASTQC } from '../modules/cruksi/fastqc/main'
include { MULTIQC } from '../modules/cruksi/multiqc/main'

workflow PIPELINE_QC {

  main:
    // Build reads channel from either samplesheet or glob
    Channel.empty().set { reads_ch }

    if ( params.input ) {
      def parsed = INGEST_SAMPLESHEET(params.input)
      reads_ch = parsed.out.reads
    } else if ( params.reads ) {
      reads_ch = Channel.fromPath(params.reads).map { p ->
        def meta = [ id: p.baseName.replaceFirst(/\.(fastq|fq)(\.gz)?$/, ''), lane: null, platform: null, center: null, batch: null ]
        tuple(meta, p)
      }
    } else {
      log.warn "No --input or --reads provided. Nothing to do."
      reads_ch = Channel.empty()
    }

    // FastQC
    Channel.empty().set { fastqc_html_ch }
    Channel.empty().set { fastqc_zip_ch }

    if ( !params.skip_fastqc ) {
      def fq = FASTQC(reads_ch)
      fastqc_html_ch = fq.out.html
      fastqc_zip_ch  = fq.out.zip
    }

    // MultiQC
    if ( !params.skip_multiqc ) {
      // Barrier: wait for FastQC to complete by collecting any output
      def done_flag = (params.skip_fastqc ? Channel.value(true) : fastqc_html_ch.collect())
      MULTIQC(done_flag)
    }

  emit:
    fastqc_html = fastqc_html_ch
    fastqc_zip  = fastqc_zip_ch
}
