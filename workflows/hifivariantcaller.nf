/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { ALIGNMENT               } from '../subworkflows/local/alignment'
include { VARIANTCALLTN           } from '../subworkflows/local/variantcalltn'
include { VARIANTCALLTO           } from '../subworkflows/local/variantcallto'
include { VARIANTANNOT            } from '../subworkflows/local/variantannot'

include { MULTIQC                } from '../modules/nf-core/multiqc/main'
include { paramsSummaryMap       } from 'plugin/nf-validation'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_hifivariantcaller_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow HIFIVARIANTCALLER {

    take:
    ch_samplesheet // channel: samplesheet read in from --input

    main:
    // Need to create additional channels to accomodate the "type" meta being added below on the fly 
    if (params.treatment_only) {
    ch_chain = ch_samplesheet.map { meta, tx, ind, ind_fai, ref, fai, chain -> [meta, chain] }
    ch_tx_bam = ch_samplesheet.map { meta, tx, ind, ind_fai, ref, fai, chain -> [meta, tx] }
    ch_ind_genome = ch_samplesheet.map { meta, tx, ind, ind_fai, ref, fai, chain -> [meta, ind] }
    ch_ind_fasta_fai = ch_samplesheet.map { meta, tx, ind, ind_fai, ref, fai, chain -> [meta, ind_fai] }
    ch_ref_genome = ch_samplesheet.map { meta, tx, ind, ind_fai, ref, fai, chain -> [meta, ref] }
    ch_ref_genome_fai = ch_samplesheet.map { meta, tx, ind, ind_fai, ref, fai, chain -> [meta, fai] }
    } else {
    ch_chain = ch_samplesheet.map { meta, tx, ctl, ind, ind_fai, ref, fai, chain -> [meta, chain] }
    ch_tx_bam = ch_samplesheet.map { meta, tx, ctl, ind, ind_fai, ref, fai, chain -> [meta, tx] }
    ch_ind_genome = ch_samplesheet.map { meta, tx, ctl, ind, ind_fai, ref, fai, chain -> [meta, ind] }
    ch_ind_fasta_fai = ch_samplesheet.map { meta, tx, ctl, ind, ind_fai, ref, fai, chain -> [meta, ind_fai] }
    ch_ref_genome = ch_samplesheet.map { meta, tx, ctl, ind, ind_fai, ref, fai, chain -> [meta, ref] }
    ch_ref_genome_fai = ch_samplesheet.map { meta, tx, ctl, ind, ind_fai, ref, fai, chain -> [meta, fai] }
    }

    ch_ref_id = ch_ref_genome.map { meta, ref -> 
                                meta = meta.id
                                [meta, ref] 
                               }.map { meta, ref ->
                                    ref_id = ref.name.toString().split('/').last().split('\\.').first()
                                    [meta, ref_id]
                               }
    ch_chain = ch_chain.map { meta, chain -> 
                              meta = meta.id 
                              [meta, chain] 
                            }

    ch_tx_bam = ch_tx_bam.map { meta, path ->  
                                meta = meta + [type:'treatment']
                                [meta, path]
                                }
    ch_ind_genome_fai = ch_ind_genome.combine(ch_ind_fasta_fai,by:0).map { meta, bam, bai -> 
                                            meta = meta.id
                                            [meta, bam , bai]
                                            }

    ch_ind_genome_tx = ch_ind_genome.map { meta, path ->  
                                meta = meta + [type:'treatment']
                                [meta, path]
                                }
    ch_ref_fasta_fai = ch_ref_genome.combine(ch_ref_genome_fai,by:0).map { meta, bam, bai -> 
                                            meta = meta.id
                                            [meta, bam , bai]
                                            }
    ch_ref_genome_tx = ch_ref_genome.map { meta, path ->  
                                meta = meta + [type:'treatment']
                                [meta, path]
                                }
    ch_ref_fai_tx = ch_ref_genome_fai.map { meta, path ->  
                                meta = meta + [type:'treatment']
                                [meta, path]
                                }
    ch_tx_bam_ind_genome = ch_tx_bam.combine(ch_ind_genome_tx,by:0)

    if (params.treatment_only) {
        println 'Treatment only!'
        ch_ctl_bam = Channel.of("/")
        ch_bam_ref = ch_tx_bam_ind_genome
    } else {
        println 'Treatment and control!'
        ch_ctl_bam = ch_samplesheet.map { meta, tx, ctl, ind, ind_fai, ref, fai, chain -> [meta, ctl] }
        ch_ctl_bam = ch_ctl_bam.map { meta, path ->  
                                meta = meta + [type:'control']
                                [meta, path]
                                }
        ch_ind_genome_ctl = ch_ind_genome.map { meta, path ->  
                                meta = meta + [type:'control']
                                [meta, path]
                                }
        ch_ref_genome_ctl = ch_ref_genome.map { meta, path ->  
                                meta = meta + [type:'control']
                                [meta, path]
                                }
        ch_ref_fai_ctl = ch_ref_genome_fai.map { meta, path ->  
                                meta = meta + [type:'control']
                                [meta, path]
                                }
        ch_ctl_bam_ind_genome = ch_ctl_bam.combine(ch_ind_genome_ctl,by:0)
        ch_bam_ref = ch_tx_bam_ind_genome.mix(ch_ctl_bam_ind_genome)
    }
    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()

    //
    // SUBWORKFLOW: Align HiFi reads to individual-specific genome and run QC
    //
    ALIGNMENT (
        ch_bam_ref
    )

    ch_multiqc_files = ch_multiqc_files.mix(ALIGNMENT.out.bam_qc.map {it[1]})
    ch_versions = ch_versions.mix(ALIGNMENT.out.versions)

    // combine bam and bai files from same sample 

    ch_bam_bai = ALIGNMENT.out.bam.combine(ALIGNMENT.out.bai, by:0)

    if (params.treatment_only) {
        ch_all_bam_bai = ch_bam_bai.map {meta, bam, bai -> 
                              meta = meta.id 
                              [meta, bam, bai] }
        ch_all_bam_bai.view()
        ch_all_bam_bai_ind_ref = ch_all_bam_bai.combine(ch_ind_genome_fai, by:0)
        ch_ind_genome_fai.view()

    //
    // SUBWORKFLOW: Call variants in tumor-only mode
    //
    VARIANTCALLTO ( ch_all_bam_bai_ind_ref )

    ch_snv_indel_vcf_ind_fasta = VARIANTCALLTO.out.snv_indel_vcf.combine(ch_ind_genome_fai, by:0)
    ch_snv_indel_vcf_ind_ref_fasta = ch_snv_indel_vcf_ind_fasta.combine(ch_ref_fasta_fai, by:0)
    ch_snv_indel_vcf_ind_ref_fasta_chain = ch_snv_indel_vcf_ind_ref_fasta.combine(ch_chain, by:0)
    ch_versions = ch_versions.mix(VARIANTCALLTO.out.versions)    
    } else {
        // need to specify custome sort function that converts items to a string, assigns a value of 0 if the string contains 'CTL' in this case, or a 1 otherwise (to the tx sample), then sorts in ascending order using the spaceship comparator operation, so the CTL sample will always be first in the tuple
        ch_all_bam_bai = ch_bam_bai.map { meta, bam, bai -> 
                                            meta = meta.id
                                            [meta, bam , bai]
                                            }.groupTuple(by:0, sort: { bam1,bam2 -> 
                                            // change the below from 'control' being 0 to control being 1 to swap which is tx and which is control
                                                     def bam1_sort = bam1.toString().contains('control') ? 0: 1 
                                                     def bam2_sort = bam2.toString().contains('control') ? 0: 1
                                                     bam1_sort.value <=> bam2_sort.value } )
        ch_all_bam_bai_ind_ref = ch_all_bam_bai.combine(ch_ind_genome_fai, by:0)

    //
    // SUBWORKFLOW: Call variants in tumor/normal mode
    //
    VARIANTCALLTN ( ch_all_bam_bai_ind_ref )

    ch_snv_indel_vcf_ind_fasta = VARIANTCALLTN.out.snv_indel_vcf.combine(ch_ind_genome_fai, by:0)
    ch_snv_indel_vcf_ind_ref_fasta = ch_snv_indel_vcf_ind_fasta.combine(ch_ref_fasta_fai, by:0)
    ch_snv_indel_vcf_ind_ref_fasta_chain = ch_snv_indel_vcf_ind_ref_fasta.combine(ch_chain, by:0)
    ch_versions = ch_versions.mix(VARIANTCALLTN.out.versions)    
    }

    //
    // SUBWORKFLOW: Liftover variants to ref genome coordinates and annotate
    //
    VARIANTANNOT ( ch_snv_indel_vcf_ind_ref_fasta_chain,
                   ch_ref_id
    )

    ch_versions = ch_versions.mix(VARIANTANNOT.out.versions)
    
    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'nf_core_pipeline_software_mqc_versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }

    //
    // MODULE: MultiQC
    //
    ch_multiqc_config        = Channel.fromPath(
        "$projectDir/assets/multiqc_config.yml", checkIfExists: true)
    ch_multiqc_custom_config = params.multiqc_config ?
        Channel.fromPath(params.multiqc_config, checkIfExists: true) :
        Channel.empty()
    ch_multiqc_logo          = params.multiqc_logo ?
        Channel.fromPath(params.multiqc_logo, checkIfExists: true) :
        Channel.empty()

    summary_params      = paramsSummaryMap(
        workflow, parameters_schema: "nextflow_schema.json")
    ch_workflow_summary = Channel.value(paramsSummaryMultiqc(summary_params))

    ch_multiqc_custom_methods_description = params.multiqc_methods_description ?
        file(params.multiqc_methods_description, checkIfExists: true) :
        file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)
    ch_methods_description                = Channel.value(
        methodsDescriptionText(ch_multiqc_custom_methods_description))

    ch_multiqc_files = ch_multiqc_files.mix(
        ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    ch_multiqc_files = ch_multiqc_files.mix(ch_collated_versions)
    ch_multiqc_files = ch_multiqc_files.mix(
        ch_methods_description.collectFile(
            name: 'methods_description_mqc.yaml',
            sort: true
        )
    )

    MULTIQC (
        ch_multiqc_files.collect(),
        ch_multiqc_config.toList(),
        ch_multiqc_custom_config.toList(),
        ch_multiqc_logo.toList()
    )

    emit:
    multiqc_report = MULTIQC.out.report.toList() // channel: /path/to/multiqc_report.html
    versions       = ch_versions                 // channel: [ path(versions.yml) ]
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
