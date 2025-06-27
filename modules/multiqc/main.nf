#!/usr/bin/env nextflow

process MULTIQC {
    label "process_low"
    container "ghcr.io/bf528/multiqc:latest"
    publishDir params.outdir
   
    input:
    path ('**/*')

    output:
    path("*html")


    script:
    """
    multiqc -f .

    """

}