include { LIFTOVER          } from '../../modules/local/liftover'
include { SIGPROFILER       } from '../../modules/local/sigprofiler'

workflow VARIANTANNOT {

    take:
    ch_snv_indel_vcf_ind_ref_fasta_chain // channel: [ val(meta), [ vcf ], [ind_fasta], [ind_fai], [ref_fasta], [ref_fai] ]
    ch_ref_id                            // channel: [ val(meta), val(reference_genome_id) ]
    main:

    ch_versions = Channel.empty()

    LIFTOVER ( ch_snv_indel_vcf_ind_ref_fasta_chain )
    ch_versions = ch_versions.mix(LIFTOVER.out.versions.first())

    ch_liftover = LIFTOVER.out.liftover_vcf.combine(LIFTOVER.out.liftover_vcf_tbi, by:0)

    ch_liftover_ref_id = ch_liftover.combine(ch_ref_id, by:0)

    ch_liftover_dir_ref_id = LIFTOVER.out.liftover_directory.combine(ch_ref_id, by:0)

    SIGPROFILER ( ch_liftover_dir_ref_id )
    ch_versions = ch_versions.mix(SIGPROFILER.out.versions.first())

    emit:
    activites_pdf       = SIGPROFILER.out.activities_pdf          // channel: [ val(meta), [ pdf ] ]
    signatures_pdf      = SIGPROFILER.out.signatures_pdf          // channel: [ val(meta), [ pdf ] ]
    stats_txt           = SIGPROFILER.out.stats_txt               // channel: [ val(meta), [ txt ] ]
    versions            = ch_versions                             // channel: [ versions.yml ]
}

