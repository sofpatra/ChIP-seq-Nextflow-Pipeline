#!/usr/bin/env nextflow

process SAMTOOLS_FLAGSTAT {
    label 'process_single'
    container 'ghcr.io/bf528/samtools:latest'
    publishDir params.outdir

    input:
    tuple val(meta), path(bam)

    output:
    path('*flagstat.txt'), emit: flagstat

    shell:
    """
    samtools flagstat -@ $task.cpus $bam > ${meta}_flagstat.txt
    """
}