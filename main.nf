nextflow.enable.dsl=2

include { PIPELINE_QC } from './workflows/qc'

workflow {
  PIPELINE_QC()
}
