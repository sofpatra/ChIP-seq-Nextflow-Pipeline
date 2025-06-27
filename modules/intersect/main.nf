#!/usr/bin/env nextflow

process INTERSECT {
    label 'process_medium'
    container 'ghcr.io/bf528/bedtools:latest'
    publishDir params.outdir

    input:
    path(narrowpeak1)
    path(narrowpeak2)

    output:
    path 'intersect.bed', emit: intersect
   
    
    shell:
    """
    bedtools intersect -a ${narrowpeak1} -b ${narrowpeak2}> intersect.bed
    """
}