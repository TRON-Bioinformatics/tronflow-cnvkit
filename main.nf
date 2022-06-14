#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { CNVKIT_BATCH } from './modules/modules/cnvkit/batch/main'

params.help= false
params.input_files = false
params.reference = false
params.intervals = false
params.output = 'output'


def helpMessage() {
    log.info params.help_message
}

if (params.help) {
    helpMessage()
    exit 0
}

if (!params.reference) {
    log.error "--reference is required"
    exit 1
}

if (! params.input_files) {
  exit 1, "--input_files is required!"
}
else {
  Channel
    .fromPath(params.input_files)
    .splitCsv(header: ['name', 'tumor_bam', 'normal_bam'], sep: "\t")
    .map{ row-> tuple([id: row.name], file(row.tumor_bam), file(row.normal_bam)) }
    .set { input_files }
}


workflow {
    CNVKIT_BATCH(input_files, params.reference, [], params.intervals, [])
}
