process SNPEFF {
    tag "$meta"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/snpeff_snpsift:5.2--e2939680b6ff2466':
        'community.wave.seqera.io/library/snpeff_snpsift:5.2--e2939680b6ff2466' }"

    input:
    tuple val(meta), path(vcf), path(tbi), val(ref_id)

    output:
    tuple val(meta), path("*.vcf"), emit: vcf
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta}"

    """
    if [[ $ref_id == "mm10" ]]; then
        echo "mm10"
        new_ref_id="GRCm38.99"
    else
        new_ref_id=$ref_id
    fi

    snpEff eff \$new_ref_id $vcf 

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        snpeff: \$(snpEff -version | cut -f2)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        snpeff: \$(snpEff -version | cut -f2)
    END_VERSIONS
    """
}
