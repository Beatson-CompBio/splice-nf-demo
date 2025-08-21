nextflow.enable.dsl=2

workflow INGEST_SAMPLESHEET {
  take:
    samplesheet_path

  main:
    Channel.fromPath(samplesheet_path)
      .map { it.text }
      .flatMap { text ->
        def lines = text.readLines().findAll { it.trim() }
        if (!lines) return []
        def header = lines.head().split(/,\s*/)
        def idx = header.collectEntries { [ (it): header.indexOf(it) ] }
        def required = [ 'sample_id', 'fastq_1' ]
        required.each { if (!idx.containsKey(it)) throw new IllegalArgumentException("Missing column: ${it}") }
        def optional = [ 'fastq_2', 'lane', 'platform', 'center', 'batch' ]
        lines.tail().collect { row ->
          def cols = row.split(/,\s*/) as List
          def sid  = cols[idx['sample_id']]
          def fq1  = file(cols[idx['fastq_1']])
          if (!fq1.name.matches(/.*\.(fastq|fq)\.gz$/)) throw new IllegalArgumentException("fastq_1 must be .fastq.gz: ${fq1}")
          def fq2  = idx.containsKey('fastq_2') && cols[idx['fastq_2']] ? file(cols[idx['fastq_2']]) : null
          if (fq2 && !fq2.name.matches(/.*\.(fastq|fq)\.gz$/)) throw new IllegalArgumentException("fastq_2 must be .fastq.gz: ${fq2}")
          def meta = [
            id: sid,
            lane: idx.containsKey('lane') ? cols[idx['lane']] : null,
            platform: idx.containsKey('platform') ? cols[idx['platform']] : null,
            center: idx.containsKey('center') ? cols[idx['center']] : null,
            batch: idx.containsKey('batch') ? cols[idx['batch']] : null,
            single_end: fq2 == null
          ]
          def tuples = [ tuple(meta, fq1) ]
          if (fq2) tuples << tuple(meta, fq2)
          return tuples
        }.flatten()
      }
      .set { reads }

  emit:
    reads = reads
}
