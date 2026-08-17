#!/bin/bash
# The interpreter used to execute the script

#“#SBATCH” directives that convey submission options:

#SBATCH --job-name=subsetBam
#SBATCH --mail-type=FAIL,END
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=30G
#SBATCH --time=2:00:00
#SBATCH --account=scjp0
#SBATCH --partition=standard
#SBATCH --mail-user=vthihong@umich.edu
#SBATCH --output=reports/subsetBam.%j.out   # STDOUT output file
#SBATCH --error=reports/subsetBam.%j.err    # ERR output file

########### Script starts
ml singularity

cd /nfs/turbo/umms-scjp-pank/vthihong/pank_scrnaseq_map/3_Prodo/results/20250408_GSE217837/starsolo/SAMN16081314-hg38/
#singularity exec /scratch/scjp_root/scjp99/vthihong/singularity-cache/porchard-default-general-20220107.img samtools index /nfs/turbo/umms-scjp-pank/vthihong/pank_scrnaseq_map/3_Prodo/results/20250408_GSE217837/starsolo/SAMN16081314-hg38/SAMN16081314-hg38.Aligned.sortedByCoord.out.bam
singularity exec /scratch/scjp_root/scjp99/vthihong/singularity-cache/porchard-sinto-20230623.img sinto filterbarcodes -b /nfs/turbo/umms-scjp-pank/vthihong/pank_scrnaseq_map/3_Prodo/results/20250408_GSE217837/starsolo/SAMN16081314-hg38/SAMN16081314-hg38.Aligned.sortedByCoord.out.bam -c /nfs/turbo/umms-scjp-pank/vthihong/texera/20260817_tiny-workflow/data/SAMN16081314_downsampled_1.7k_barcodes.tsv --barcodetag CB --outdir /nfs/turbo/umms-scjp-pank/vthihong/texera/20260817_tiny-workflow/data/
