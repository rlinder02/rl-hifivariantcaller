include { CLAIRSTN          } from '../../modules/local/clairstn'

workflow VARIANTCALLTN {

    take:
    ch_bams_bais       // channel: [ val(meta), [ ctl_bam ], [ tx_bam ], [ ctl_bai ], [ tx_bai ]] 
    ch_ind_genome_fai  // channel: [ val(meta), [ ind_ref_fastsa ], [ ind_ref_fasta_fai]]

    main:

    ch_versions = Channel.empty()

    CLAIRSTN ( ch_bams_bais,
               ch_ind_genome_fai
    )

    ch_versions = ch_versions.mix(CLAIRSTN.out.versions.first())

    emit:
    bam      = SAMTOOLS_SORT.out.bam           // channel: [ val(meta), [ bam ] ]
    bai      = SAMTOOLS_INDEX.out.bai          // channel: [ val(meta), [ bai ] ]
    csi      = SAMTOOLS_INDEX.out.csi          // channel: [ val(meta), [ csi ] ]

    versions = ch_versions                     // channel: [ versions.yml ]
}

