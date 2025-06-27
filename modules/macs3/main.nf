#!/usr/bin/env nextflow

process CALLPEAKS {
    label 'process_high'
    container 'quay.io/biocontainers/macs3:3.0.3--py39h0699b22_0'
    publishDir params.outdir

    input:
    tuple val(rep), path(IP), path(CONTROL)
    val(macs3_genome)

    output:
    tuple val(rep), path('*.narrowPeak'), emit: peaks
   
    
    shell:
    """
    macs3 callpeak -t $IP -c $CONTROL -f BAM -g $macs3_genome -n $rep 
    """
}