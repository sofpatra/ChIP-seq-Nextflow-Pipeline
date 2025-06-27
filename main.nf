#!/usr/bin/env nextflow

include {FASTQC} from './modules/fastqc'
include { TRIM } from './modules/trimmomatic'
include { BOWTIE2_BUILD } from './modules/bowtie2_index'
include { BOWTIE2_ALIGN } from './modules/bowtie2_align'
include { SAMTOOLS_INDEX } from './modules/samtools_index'
include { SAMTOOLS_SORT } from './modules/samtools_sort'
include { SAMTOOLS_FLAGSTAT } from './modules/samtools_flagstat'
include { MULTIQC } from './modules/multiqc'
include { BAM_COVERAGE } from './modules/bam_coverage'
include { BIGWIG_SUMMARY } from './modules/bigwig_summary'
include { PLOT_CORRELATION } from './modules/plot_correlation'
include { CALLPEAKS } from './modules/macs3'
include { INTERSECT } from './modules/intersect/main.nf'
include { FILTER_BLACKLIST } from './modules/filter_blacklist/main.nf'
include { COMPUTE_MATRIX } from './modules/compute_martix/main.nf'
include { PLOT_PROFILE } from './modules/plot_profile/main.nf'
include { FIND_MOTIFS } from './modules/find_motifs/main.nf'
include { ANNOTATE } from './modules/homer/main.nf'



//construct read channel
workflow {
Channel.fromPath(params.samplesheet)
    | splitCsv(header:true)
    | map{row -> tuple(row.name, file(row.path))}
    | set{read_ch}

//call processes
FASTQC(read_ch)

TRIM(read_ch, params.adapter_fa)

BOWTIE2_BUILD(params.genome)

BOWTIE2_ALIGN(read_ch, BOWTIE2_BUILD.out.index,BOWTIE2_BUILD.out.name)

SAMTOOLS_SORT(BOWTIE2_ALIGN.out.bam)
SAMTOOLS_INDEX(SAMTOOLS_SORT.out.sorted)

SAMTOOLS_FLAGSTAT(SAMTOOLS_INDEX.out)


// Collect individual outputs into flat lists of paths
trim_logs     = TRIM.out.log.flatten()
fastqc_zips   = FASTQC.out.zip.flatten()
flagstat_outs = SAMTOOLS_FLAGSTAT.out.flagstat.flatten()

// Merge all paths into a single channel and collect
multiqc_ch = trim_logs
    .concat(fastqc_zips)
    .concat(flagstat_outs)
    .collect()

multiqc_ch.view()

// Run MultiQC on the collected files
MULTIQC(multiqc_ch)

//BAMCOVERAGE
BAM_COVERAGE(SAMTOOLS_INDEX.out)

BIGWIG_SUMMARY_INPUT = BAM_COVERAGE.out
    .map { it[1] }         // extract just the `.bw` paths
    .collect()
//  run summary
BIGWIG_SUMMARY(BIGWIG_SUMMARY_INPUT)
//plot correlation using spearman
PLOT_CORRELATION(BIGWIG_SUMMARY.out.bwsummary)


BOWTIE2_ALIGN.out
    | map { name, path -> tuple(name.split('_')[1], [(path.baseName.split('_')[0]): path]) }
    | groupTuple(by: 0)
    | map { rep, maps -> tuple(rep, maps[0] + maps[1])}
    | map { rep, samples -> tuple(rep, samples.IP, samples.INPUT)}
    | set { peakcalling_ch }

CALLPEAKS(peakcalling_ch, params.macsgenome)

rep1_peak = CALLPEAKS.out.filter { it[0] == 'rep1' }.map { it[1] }
rep2_peak = CALLPEAKS.out.filter { it[0] == 'rep2' }.map { it[1] }

INTERSECT(rep1_peak, rep2_peak)

FILTER_BLACKLIST(INTERSECT.out.intersect, params.blacklist)

// annotate peaks to their nearest genome feature
ANNOTATE(FILTER_BLACKLIST.out.filtered_peaks, params.genome, params.gtf)

bw_ch = Channel.fromPath("results/*.bw")
               .filter { it.name.contains("IP") }

COMPUTE_MATRIX(bw_ch, params.bedref)

PLOT_PROFILE(COMPUTE_MATRIX.out)

FIND_MOTIFS(FILTER_BLACKLIST.out.filtered_peaks, params.genome)

    }