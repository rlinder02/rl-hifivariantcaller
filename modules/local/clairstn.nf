process CLAIRSTN {
    tag "$meta"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://docker.io/hkubal/clairs:v0.4.0':
        'docker.io/hkubal/clairs:v0.4.0' }"

    input:
    tuple val(meta), path(bam), path(bai), path(ind_fasta), path(ind_fasta_fai)

    output:
    tuple val(meta), path("${meta}/snv.vcf.gz")      , emit: snv_vcf
    tuple val(meta), path("${meta}/snv.vcf.gz.tbi")  , emit: snv_vcf_tbi
    tuple val(meta), path("${meta}/indel.vcf.gz")    , emit: indel_vcf
    tuple val(meta), path("${meta}/indel.vcf.gz.tbi"), emit: indel_vcf_tbi
    path "versions.yml"                              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta}"
    """
    run_clairs \\
	    --normal_bam_fn ${bam[0]} \\
	    --tumor_bam_fn ${bam[1]} \\
        --ref_fn $ind_fasta \\
        --threads $task.cpus \\
        --platform hifi_revio \\
        --output_dir $prefix \\
        --sample_name $prefix \\
        --enable_indel_calling \\
        $args	

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        clairs: \$(run_clairs --version | sed 's/run_clairs //')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.snv.vcf.gz
    touch ${prefix}.indel.vcf.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        clairs: \$(run_clairs --version | sed 's/run_clairs //')
    END_VERSIONS
    """
}
