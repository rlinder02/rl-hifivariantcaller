include { ALIGN          } from '../../modules/local/align'
include { QUALIMAP_BAMQC } from '../../modules/nf-core/qualimap/bamqc/main'

workflow ALIGNMENT {

    take:
    ch_samplesheet // channel: [ val(meta), path(tx.bam), path(ctl.bam), path(ind.fasta), path(ref.fasta), path(chain) ]

    main:

    ch_tx_bam = ch_samplesheet.map { meta, tx, ctl, ind, ref, chain -> [meta, tx] }
    ch_ind_genome = ch_samplesheet.map { meta, tx, ctl, ind, ref, chain -> [meta, ind] }
    ch_ref_genome = ch_samplesheet.map { meta, tx, ctl, ind, ref, chain -> [meta, ref] }
    ch_tx_bam_ind_genome = ch_tx_bam.combine(ch_ind_genome,by:0)
    if (params.treatment_only) {
        ch_ctl_bam = Channel.of("/")
        ch_bam_ref = ch_tx_bam_ind_genome
    } else {
        ch_ctl_bam = ch_samplesheet.map { meta, tx, ctl, ind, ref, chain -> [meta, ctl] }
        ch_ctl_bam_ind_genome = ch_ctl_bam.combine(ch_ind_genome,by:0)
        ch_bam_ref = ch_tx_bam_ind_genome.mix(ch_ctl_bam_ind_genome)
    }
    ch_versions = Channel.empty()


    ALIGN ( ch_bam_ref )
    ch_versions = ch_versions.mix(ALIGN.out.versions.first())

    QUALIMAP_BAMQC ( ALIGN.out.bam )
    ch_versions = ch_versions.mix(QUALIMAP_BAMQC.out.versions.first())

    emit:
    bam      = ALIGN.out.bam                   // channel: [ val(meta), [ bam ] ]
    bam_qc   = QUALIMAP_BAMQC.out.results      // channel: [ val(meta), [ outdir ] ]
    versions = ch_versions                     // channel: [ versions.yml ]
}

