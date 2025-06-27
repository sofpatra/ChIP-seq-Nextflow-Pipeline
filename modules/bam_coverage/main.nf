#!/usr/bin/env nextflow

process BAM_COVERAGE {
    label 'process_medium'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir params.outdir

    input:
    tuple val(meta), path(bam), path(bai)

    output:
    tuple val(meta), path('*.bw'), emit: bigwig

    shell:
    """
    bamCoverage -b $bam -o ${meta}.bw -p $task.cpus
    """
}