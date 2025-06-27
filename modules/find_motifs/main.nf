#!/usr/bin/env nextflow

process FIND_MOTIFS {
    label 'process_low'
    container 'ghcr.io/bf528/homer:latest'
    publishDir params.outdir

    input:
    path(filtered_peaks)
    path(genome) 

    output:
    path('motifs/')
   
    
    shell:
    """
    findMotifsGenome.pl $filtered_peaks $genome motifs/ -size 200 -mask 
    """
}