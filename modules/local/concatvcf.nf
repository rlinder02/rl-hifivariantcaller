process CONCATVCF {
    tag "$meta"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://docker.io/rlinder02/vcfliftover:v0.0.1':
        'docker.io/rlinder02/vcfliftover:v0.0.1' }"

    input:
    tuple val(meta), path(snv_vcf), path(snv_tbi), path(indel_vcf), path(indel_tbi)

    output:
    tuple val(meta), path("*.combined_filtered.vcf.gz"), emit: vcf
    path "versions.yml"                                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta}"
    """
    bcftools \\
        concat \\
        --allow-overlaps \\
        -Ou \\
        --threads $task.cpus \\
        $snv_vcf \\
        $indel_vcf \\
    | \\
    bcftools \\
        filter \\
        --IndelGap 5 \\
        -i 'FILTER="PASS"' \\
        -Oz \\
        --threads $task.cpus \\
        -o ${prefix}_combined_filtered.vcf.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bcftools: \$(bcftools --version | head -1 | sed 's/bcftools //')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bcftools: \$(bcftools --version | head -1 | sed 's/bcftools //')
    END_VERSIONS
    """
}
