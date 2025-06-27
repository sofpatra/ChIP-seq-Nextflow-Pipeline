process PLOT_CORRELATION {
    label 'process_medium'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir params.outdir

    input:
    path(npz)

    output:
    path('*.png')
   
    //multiBigwigSummary bins -b file1.bw file2.bw -o results.npz
    shell:
    """
    plotCorrelation -in $npz -c spearman -p heatmap --plotNumbers -o plot_with_numbers.png 
    """
}