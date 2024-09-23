process CLAIRSTN {
    tag "$meta"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://docker.io/hkubal/clairs:v0.3.1':
        'docker.io/hkubal/clairs:v0.3.1' }"

    input:
    tuple val(meta), path(ctl_bam), path(tx_bam), path(ctl_bai), path(tx_bai), path(ind_fasta), path(ind_fasta_fai)

    output:
    tuple val(meta), path("${prefix}/snv.vcf.gz")      , emit: snv_vcf
    tuple val(meta), path("${prefix}/snv.vcf.gz.tbi")  , emit: snv_vcf_tbi
    tuple val(meta), path("${prefix}/indel.vcf.gz")    , emit: indel_vcf
    tuple val(meta), path("${prefix}/indel.vcf.gz.tbi"), emit: indel_vcf_tbi
    path "versions.yml"                                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta}"
    """
    run_clairs \\
	    --normal_bam_fn $ctl_bam \\
	    --tumor_bam_fn $tx_bam \\
        --ref_fn $ind_fasta \\
        --threads $task.cpus \\
        --platform hifi_revio \\
        --output_dir $prefix \\
        --sample_name $prefix \\
        --snv_min_af 0.005 \\
        --enable_indel_calling \\
        --min_coverage 1 \\
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
