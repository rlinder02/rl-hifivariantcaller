process ALIGN {
    tag "${meta.id}.${meta.type}"
    label 'process_medium'

    conda "bioconda::pbmm2=1.13.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/pbmm2:1.13.1--9fdbcfc25bbe21c9':
        'community.wave.seqera.io/library/pbmm2:1.13.1--9fdbcfc25bbe21c9' }"

    input:
    tuple val(meta), path(bam), path(fasta)

    output:
    tuple val(meta), path("*.sorted.bam")    , emit: bam
    tuple val(meta), path("*.sorted.bam.bai"), emit: bai
    path "versions.yml"                      , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}.${meta.type}"
    """
    pbmm2 \\
        align \\
        $fasta \\
        $bam \\
        ${prefix}.sorted.bam \\
        --sort \\
        -j $task.cpus \\
        --preset HIFI \\
        -A 2 \\
        --unmapped \\
        $args 

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pbmm2: \$(pbmm2 --version | head -1)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.sorted.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pbmm2: \$(pbmm2 --version | head -1)
    END_VERSIONS
    """
}
