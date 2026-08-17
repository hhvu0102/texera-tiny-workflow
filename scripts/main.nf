#!/usr/bin/env nextflow

nextflow.enable.dsl=2
IONICE = 'ionice -c2 -n7'

def get_star_index (genome) {
	return(params.star_index[genome])
}

def get_gtf (genome) {
	return(params.gtf[genome])
}

def get_chrom_sizes (genome) {
	return(get_star_index(genome) + '/chrNameLength.txt')
}
	
def get_genome (library) {
	return(params.libraries[library].genome)
}

def library_to_readgroups (library) {
	return(params.libraries[library].readgroups.keySet())
}

def library_and_readgroup_to_fastqs (library, readgroup) {
	return(params.libraries[library].readgroups[readgroup])
}


process qc {

    memory '25 GB'
    publishDir "${params.results}/qc"
    tag "${library}-${genome}"
    container 'library://porchard/default/general:20220107'
    cpus 1
    time '5h'

    input:
    tuple val(library), val(genome), path(bam), path(matrix), path(barcodes)

    output:
    tuple val(library), val(genome), path("${library}-${genome}.qc.txt")

    """
    qc-from-starsolo.py ${bam} ${matrix} ${barcodes} > ${library}-${genome}.qc.txt
    """

}


process plot_qc {

    memory '15 GB'
    publishDir "${params.results}/qc"
    tag "${library}-${genome}"
    container 'library://porchard/default/dropkick:20220225'
    cpus 1
    time '5h'

    input:
    tuple val(library), val(genome), path(metrics)

    output:
    tuple val(library), val(genome), path("${library}-${genome}.metrics.png"), path("${library}-${genome}.suggested-thresholds.tsv")

    """
    plot-qc-metrics.py --prefix ${library}-${genome}. $metrics
    """

}


process interactive_barcode_rank_plot {

    memory '15 GB'
    publishDir "${params.results}/interactive-barcode-rank-plots"
    tag "${library}-${genome}"
    container "docker://porchard/plotly:20230705"
    cpus 1
    time '3h'

    input:
    tuple val(library), val(genome), path(bam), path(matrix), path(barcodes)

    output:
    path("${library}-${genome}.barcode-rank-plot.html")


    """
    interactive-barcode-rank-plot.py ${matrix} ${library}-${genome}.barcode-rank-plot.html
    """

}

workflow {
    qc_inputs = Channel
        .fromPath(params.samplesheet)
        .splitCsv(header: true)
        .map { row ->
            tuple(row.library, row.genome, file(row.bam), file(row.matrix), file(row.barcodes))
        }

    qc_out = qc(qc_inputs)
    plot_qc(qc_out)
    interactive_barcode_rank_plot(qc_inputs)
}

