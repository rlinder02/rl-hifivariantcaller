include { CLAIRSTN           } from '../../modules/local/clairstn'
include { CONCATVCF          } from '../../modules/local/concatvcf'

workflow VARIANTCALLTN {

    take:
    ch_bams_bai_ind_refs       // channel: [ val(meta), [ ctl_bam, tx_bam ], [ ctl_bai, tx_bai ], [ ind_fasta ], [ ind_fasta_fai ]] 
    
    main:
    ch_versions = Channel.empty()

    CLAIRSTN ( ch_bams_bai_ind_refs )
    ch_versions = ch_versions.mix(CLAIRSTN.out.versions.first())

    ch_snv_tbi = CLAIRSTN.out.snv_vcf.combine(CLAIRSTN.out.snv_vcf_tbi,by:0)
    ch_indel_tbi = CLAIRSTN.out.indel_vcf.combine(CLAIRSTN.out.indel_vcf_tbi,by:0)
    ch_snv_indel = ch_snv_tbi.combine(ch_indel_tbi, by:0)

    CONCATVCF ( ch_snv_indel )
    ch_versions = ch_versions.mix(CONCATVCF.out.versions.first())

    emit:
    snv_indel_vcf           = CONCATVCF.out.vcf             // channel: [ val(meta), [ vcf ] ]
    versions                = ch_versions                   // channel: [ versions.yml ]
}

