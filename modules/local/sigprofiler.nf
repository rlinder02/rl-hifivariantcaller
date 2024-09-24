process SIGPROFILER {
    tag "$meta"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/sigprofilerassignment_sigprofilerplotting:846b7d5b7ed64e15':
        'community.wave.seqera.io/library/sigprofilerassignment_sigprofilerplotting:846b7d5b7ed64e15' }"

    input:
    tuple val(meta), path(vcf), path(tbi), val(ref_id)

    output:
    tuple val(meta), path("${meta}.mut.profile/Activites/*.pdf")       , emit: activities_pdf
    tuple val(meta), path("${meta}.mut.profile/Signatures/*.pdf")      , emit: signatures_pdf
    tuple val(meta), path("${meta}.mut.profile/Signatures/*_Stats.txt"), emit: stats_txt
    path "versions.yml"                                                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta}"
    """
    profile_mutations.py $vcf ${prefix}.mut.profile $ref_id  

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
