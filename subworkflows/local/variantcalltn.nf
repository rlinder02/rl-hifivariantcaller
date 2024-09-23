include { CLAIRSTN          } from '../../modules/local/clairstn'

workflow VARIANTCALLTN {

    take:
    ch_bams_bai_ind_refs       // channel: [ val(meta), [ ctl_bam ], [ tx_bam ], [ ctl_bai ], [ tx_bai ], [ ind_fasta ], [ ind_fasta_fai ]] 
    
    main:
    ch_versions = Channel.empty()

    CLAIRSTN ( ch_bams_bai_ind_refs )

    ch_versions = ch_versions.mix(CLAIRSTN.out.versions.first())

    emit:
    clairs_snv_vcf          = CLAIRSTN.out.snv_vcf          // channel: [ val(meta), [ vcf ] ]
    clairs_indel_vcf        = CLAIRSTN.out.indel_vcf        // channel: [ val(meta), [ vcf ] ]
    clairs_snv_vcf_tbi      = CLAIRSTN.out.snv_vcf_tbi      // channel: [ val(meta), [ tbi ] ]
    clairs_indel_vcf_tbi    = CLAIRSTN.out.indel_vcf_tbi    // channel: [ val(meta), [ tbi ] ]
    versions                = ch_versions                   // channel: [ versions.yml ]
}

