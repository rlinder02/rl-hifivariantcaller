process LIFTOVER {
    tag "$meta"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://docker.io/rlinder02/vcfliftover:v0.0.1':
        'docker.io/rlinder02/vcfliftover:v0.0.1' }"

    input:
    tuple val(meta), path(vcf), path(ind_fasta), path(ind_fasta_fai), path(ref_fasta), path(ref_fasta_fai), path(chain)

    output:
    tuple val(meta), path("*.liftover.vcf.gz")      , emit: liftover_vcf
    tuple val(meta), path("*.liftover.vcf.gz.tbi")  , emit: liftover_vcf_tbi
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta}"
    """
    bcftools +liftover \\
        -Ou $vcf \\
        -- \\
        -s $ind_fasta \\
        -f $ref_fasta \\
        -c $chain \\
        --reject ${prefix}.rejected.vcf \\
        --write-src \\
    | \\
    bcftools sort -Oz -o ${prefix}.liftover.vcf.gz -W=tbi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bcftools: \$(bcftools --version | head -1 | sed 's/bcftools //')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta}"
    """
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bcftools: \$(bcftools --version | head -1 | sed 's/bcftools //')
    END_VERSIONS
    """
}
