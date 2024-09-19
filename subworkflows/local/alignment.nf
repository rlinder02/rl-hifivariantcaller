include { ALIGN          } from '../../modules/local/align'
include { QUALIMAP_BAMQC } from '../../modules/nf-core/qualimap/bamqc/main'

workflow ALIGNMENT {

    take:
    ch_bam_ref // channel: [ val(meta), path(bam), path(ind.fasta) ]

    main:
    ch_versions = Channel.empty()

    ALIGN ( ch_bam_ref )
    ch_versions = ch_versions.mix(ALIGN.out.versions.first())

    QUALIMAP_BAMQC ( ALIGN.out.bam )
    ch_versions = ch_versions.mix(QUALIMAP_BAMQC.out.versions.first())

    emit:
    bam      = ALIGN.out.bam                   // channel: [ val(meta), [ bam ] ]
    bai      = ALIGN.out.bai                   // channel: [ val(meta), [ bai ] ]
    bam_qc   = QUALIMAP_BAMQC.out.results      // channel: [ val(meta), [ outdir ] ]
    versions = ch_versions                     // channel: [ versions.yml ]
}

