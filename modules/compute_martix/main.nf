#!/usr/bin/env nextflow

process COMPUTE_MATRIX {
    label 'process_medium'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir params.outdir

    input:
    path bw_file
    path bed_file

    output:
    path "matrix_*.gz"

    script:
    def base_name = bw_file.getBaseName().replaceAll(/\.bw$/, '')
    """
    computeMatrix scale-regions -S ${bw_file} -R ${bed_file} -b 2000 -a 2000 --skipZeros --outFileName matrix_${base_name}.gz
    """
}
