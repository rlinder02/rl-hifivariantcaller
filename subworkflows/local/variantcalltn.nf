include { CLAIRSTN          } from '../../modules/local/clairstn'

workflow VARIANTCALLTN {

    take:
    ch_bam // channel: [ val(meta), [ bam ] ]
    ch_bai 
    ch_samplesheet

    main:
    ch_bam_bai = ch_bam.combine(ch_bai,by:0)

    // Need to maybe use the cross operator to combine the matched treatment/control bam_bai channels based on just the meta.id field (see the docs on cross)

    ch_versions = Channel.empty()

    CLAIRSTN ( ch_bam_bai )

    emit:
    bam      = SAMTOOLS_SORT.out.bam           // channel: [ val(meta), [ bam ] ]
    bai      = SAMTOOLS_INDEX.out.bai          // channel: [ val(meta), [ bai ] ]
    csi      = SAMTOOLS_INDEX.out.csi          // channel: [ val(meta), [ csi ] ]

    versions = ch_versions                     // channel: [ versions.yml ]
}

