#!/usr/bin/env nextflow

process BIGWIG_SUMMARY {
    label 'process_medium'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir params.outdir

    input:
    path(bws)

    output:
    path('bw_all.npz'), emit: bwsummary
   
    //multiBigwigSummary bins -b file1.bw file2.bw -o results.npz
    shell:
    """
    multiBigwigSummary bins -b ${bws.join(' ')} --labels ${bws.baseName.join(' ')} -o bw_all.npz -p $task.cpus
    """
}