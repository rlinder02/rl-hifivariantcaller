include { CLAIRSTN          } from '../../modules/local/clairstn'

workflow VARIANTCALLTN {

    take:
    ch_bam // channel: [ val(meta), [ bam ] ]
    ch_bai 
    ch_samplesheet

    main:

    ch_versions = Channel.empty()

    CLAIRSTN ( ch_bam_bai )

    emit:
    bam      = SAMTOOLS_SORT.out.bam           // channel: [ val(meta), [ bam ] ]
    bai      = SAMTOOLS_INDEX.out.bai          // channel: [ val(meta), [ bai ] ]
    csi      = SAMTOOLS_INDEX.out.csi          // channel: [ val(meta), [ csi ] ]

    versions = ch_versions                     // channel: [ versions.yml ]
}

