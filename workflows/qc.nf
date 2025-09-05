nextflow.enable.dsl=2

include { INGEST_SAMPLESHEET } from '../subworkflows/cruksi/ingest/main'
include { FASTQC } from '../modules/cruksi/fastqc/main'
include { MULTIQC } from '../modules/cruksi/multiqc/main'

workflow PIPELINE_QC {

  main:
    // Build reads channel from either samplesheet or glob
    // Handle defaults for splice_cruksi_hpc profile
    def effective_input = params.input
    def effective_reads = params.reads

    // Set defaults for splice_cruksi_hpc profile when neither input nor reads specified
    if (!effective_input && !effective_reads && workflow.profile.contains('splice_cruksi_hpc')) {
      // Check if samplesheet exists, otherwise fall back to glob
      def default_samplesheet = file("../input_data/data/samplesheet.csv")
      if (default_samplesheet.exists()) {
        effective_input = "../input_data/data/samplesheet.csv"
        log.info "Using default samplesheet: ${effective_input}"
      } else {
        effective_reads = "../input_data/data/*.fastq.gz"
        log.info "Samplesheet not found, using default glob: ${effective_reads}"
      }
    }

    if ( effective_input ) {
      reads_ch = INGEST_SAMPLESHEET(effective_input)
    } else if ( effective_reads ) {
      reads_ch = Channel.fromPath(effective_reads, checkIfExists: false).map { p ->
        def meta = [ id: p.baseName.replaceAll(/\.(fastq|fq)(\.gz)?$/, ''), lane: null, platform: null, center: null, batch: null ]
        tuple(meta, p)
      }
    } else {
      log.warn "No --input or --reads provided. Nothing to do."
      reads_ch = Channel.empty()
    }

    // Initialize channels
    ch_multiqc_files = Channel.empty()
    ch_multiqc_config = params.multiqc_config ? 
        Channel.fromPath(params.multiqc_config, checkIfExists: true) : 
        Channel.fromPath("${projectDir}/assets/multiqc_config.yml", checkIfExists: true)


    // FastQC
    if ( !params.skip_fastqc ) {
      fq_results = FASTQC(reads_ch)
      fastqc_html_ch = fq_results.html
      fastqc_zip_ch  = fq_results.zip
      // Collect FastQC outputs for MultiQC
      ch_multiqc_files = ch_multiqc_files.mix(
         FASTQC.out.zip.map { meta, files -> files }.flatten()
        )
    } else {
      fastqc_html_ch = Channel.empty()
      fastqc_zip_ch = Channel.empty()
    }

    // MultiQC
    if (!params.skip_multiqc) {
        // Collect all files for MultiQC
        ch_multiqc_files
            .collect()
            .map { files -> files.size() > 0 ? files : [] }
            .filter { it.size() > 0 }
            .set { ch_multiqc_input }

        MULTIQC(
            ch_multiqc_input,
            ch_multiqc_config.first()
        )
    }


emit:
    fastqc_html = fastqc_html_ch
    fastqc_zip  = fastqc_zip_ch
}
