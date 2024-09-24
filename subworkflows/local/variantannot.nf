include { LIFTOVER          } from '../../modules/local/liftover'

workflow VARIANTANNOT {

    take:
    ch_snv_indel_vcf_ind_ref_fasta_chain // channel: [ val(meta), [ vcf ], [ind_fasta], [ind_fai], [ref_fasta], [ref_fai] ]

    main:

    ch_versions = Channel.empty()

    LIFTOVER ( ch_snv_indel_vcf_ind_ref_fasta_chain )
    ch_versions = ch_versions.mix(LIFTOVER.out.versions.first())

    emit:
    vcf      = LIFTOVER.out.liftover_vcf              // channel: [ val(meta), [ vcf ] ]
    tbi      = LIFTOVER.out.liftover_vcf_tbi          // channel: [ val(meta), [ tbi ] ]
    versions = ch_versions                            // channel: [ versions.yml ]
}

