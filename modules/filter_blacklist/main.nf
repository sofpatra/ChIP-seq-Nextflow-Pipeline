#!/usr/bin/env nextflow

process FILTER_BLACKLIST {
    label 'process_medium'
    container 'ghcr.io/bf528/bedtools:latest'
    publishDir params.outdir

    input:
    path(peaks)
    path(blacklist)

    output:
    path 'filtered_peaks.bed', emit: filtered_peaks
   
    
    shell:
    """
    bedtools intersect -v -a ${peaks} -b ${blacklist}> filtered_peaks.bed
    """
}