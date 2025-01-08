include { CLAIRSTO           } from '../../modules/local/clairsto'
include { CONCATVCF          } from '../../modules/local/concatvcf'

workflow VARIANTCALLTO {

    take:
    ch_bams_bai_ind_refs       // channel: [ val(meta), [ tx_bam ], [ tx_bai ], [ ind_fasta ], [ ind_fasta_fai ]] 
    
    main:
    ch_versions = Channel.empty()

    CLAIRSTO ( ch_bams_bai_ind_refs )
    ch_versions = ch_versions.mix(CLAIRSTO.out.versions.first())

    ch_snv_tbi = CLAIRSTO.out.snv_vcf.combine(CLAIRSTO.out.snv_vcf_tbi,by:0)
    ch_indel_tbi = CLAIRSTO.out.indel_vcf.combine(CLAIRSTO.out.indel_vcf_tbi,by:0)
    ch_snv_indel = ch_snv_tbi.combine(ch_indel_tbi, by:0)

    CONCATVCF ( ch_snv_indel )
    ch_versions = ch_versions.mix(CONCATVCF.out.versions.first())

    emit:
    snv_indel_vcf           = CONCATVCF.out.vcf             // channel: [ val(meta), [ vcf ] ]
    versions                = ch_versions                   // channel: [ versions.yml ]
}