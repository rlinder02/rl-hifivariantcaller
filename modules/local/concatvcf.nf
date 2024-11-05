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
    tuple val(meta), path("${meta}.output")                   , emit: concat_directory
    tuple val(meta), path("*.combined.corrected.vcf.gz")      , emit: concat_vcf
    tuple val(meta), path("*.combined.corrected.vcf.gz.tbi")  , emit: concat_vcf_tbi
    path "versions.yml"                                       , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta}"
    """
    bcftools \\
        concat \\
        --allow-overlaps \\
        -O z \\
        --threads $task.cpus \\
        --output ${prefix}.combined.vcf.gz \\
        $snv_vcf \\
        $indel_vcf \\
        $args	
    zcat ${prefix}.combined.vcf.gz | sed 's/FORMAT=<ID=AF,Number=1/FORMAT=<ID=AF,Number=A/' > ${prefix}.combined.corrected.vcf.gz
    mkdir -p ${prefix}.output
    bcftools sort --output-type z -o ${prefix}.sorted.vcf.gz -W=tbi ${prefix}.combined.corrected.vcf.gz
    zcat ${prefix}.combined.corrected.vcf.gz > ${prefix}.combined.corrected.vcf
    mv ${prefix}.combined.corrected.vcf ${prefix}.output/


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
