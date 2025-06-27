#!/usr/bin/env nextflow

process PLOT_PROFILE {
    label 'process_medium'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir params.outdir

    input:
    path matrix

    output:
    path "*.png", emit: profile

    script:
    def base = matrix.getBaseName().replaceAll(/\.gz$/, '')
    """
    plotProfile -m $matrix -out ${base}_profile.png
    """
}