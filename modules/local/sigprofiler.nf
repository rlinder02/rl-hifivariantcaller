process SIGPROFILER {
    tag "$meta"
    label 'process_medium'
    debug true

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/sigprofilerassignment_sigprofilerplotting:846b7d5b7ed64e15':
        'community.wave.seqera.io/library/sigprofilerassignment_sigprofilerplotting:846b7d5b7ed64e15' }"
    containerOptions = "--user root"

    input:
    tuple val(meta), path(vcf_dir), val(ref_id)

    output:
    tuple val(meta), path("${meta}.mut.profile/Assignment_Solution/Activites/*.pdf")           , emit: activities_pdf
    tuple val(meta), path("${meta}.mut.profile/Assignment_Solution/Signatures/*.pdf")          , emit: signatures_pdf
    tuple val(meta), path("${meta}.mut.profile/Assignment_Solution/Solution_Stats/*_Stats.txt"), emit: stats_txt
    path "versions.yml"                                                                        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta}"
    """
    echo $vcf_dir
    profile_mutations.py $vcf_dir ${prefix}.mut.profile $ref_id  

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        SigProfilerAssignment: \$(pip show SigProfilerAssignment | head -2 | tail -1)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta}"
    """
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        SigProfilerAssignment: \$(pip show SigProfilerAssignment | head -2 | tail -1)
    END_VERSIONS
    """
}
