#settings
export exdir=$HOME/ngs/tool/exp_quant #path to exp_quant
export annot=$exdir/bmexon_vs_refseq_hsmmdmbm_blastx.txt #patn to annotationfile
export resultname=daizo_tes_vs_ova_l5d3 #outputname
#sample:write names of salmon directory on row7-12 below
<< COMMENTOUT
Tb166_quant
Tb167_quant
Tb168_quant
Tb169_quant
Tb170_quant
Tb171_quant
COMMENTOUT
################################################################################
source /Users/ryusei/miniconda3/etc/profile.d/conda.sh
conda init
conda activate edger
cat $exdir/run.sh | sed -n 7,12p > list.txt
bash $exdir/exp_quant.sh
