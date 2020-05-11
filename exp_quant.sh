
################################################################################
cd $exdir/tmp/


#get_transcriptsid
cat $exdir/salmon_result/`sed -n 1p $exdir/list.txt`/quant.sf | \
cut -f 1 > id

#merge_readcount
for name in `cat $exdir/list.txt`
do
  cat $exdir/salmon_result/${name}/quant.sf | cut -f 5 > pre_${name}
  cat pre_${name} | sed -e "s/NumReads/rcount_${name}/" > $exdir/rcount/ind/rcount_${name}
done

paste id \
$exdir/rcount/ind/rcount_`sed -n 1p $exdir/list.txt` \
$exdir/rcount/ind/rcount_`sed -n 2p $exdir/list.txt` \
$exdir/rcount/ind/rcount_`sed -n 3p $exdir/list.txt` \
$exdir/rcount/ind/rcount_`sed -n 4p $exdir/list.txt` \
$exdir/rcount/ind/rcount_`sed -n 5p $exdir/list.txt` \
$exdir/rcount/ind/rcount_`sed -n 6p $exdir/list.txt` \
> id_rcount

mv id_rcount $exdir/rcount/${resultname}_rcount.tsv
rm $exdir/tmp/pre_*


#merge_tpm
for name in `cat $exdir/list.txt`
do
  cat $exdir/salmon_result/${name}/quant.sf | cut -f 4 > pre_${name}
  cat pre_${name} | sed -e "s/TPM/TPM_${name}/" > $exdir/tpm/ind/tpm_${name}
done

paste id \
$exdir/tpm/ind/tpm_`sed -n 1p $exdir/list.txt` \
$exdir/tpm/ind/tpm_`sed -n 2p $exdir/list.txt` \
$exdir/tpm/ind/tpm_`sed -n 3p $exdir/list.txt` \
$exdir/tpm/ind/tpm_`sed -n 4p $exdir/list.txt` \
$exdir/tpm/ind/tpm_`sed -n 5p $exdir/list.txt` \
$exdir/tpm/ind/tpm_`sed -n 6p $exdir/list.txt` \
> id_tpm

mv id_tpm $exdir/tpm/${resultname}_tpm.tsv
rm $exdir/tmp/id
rm $exdir/tmp/pre_*
rm $exdir/list.txt

#edgeR
cd $exdir/r/
cp $exdir/rcount/${resultname}_rcount.tsv $exdir/r/${resultname}_rcount.tsv
cat edgeR.R | sed -e "s/rcounttable/${resultname}/g" > edgeR_tmp.R
rscript edgeR_tmp.R
rm $exdir/r/${resultname}_rcount.tsv
rm edgeR_tmp.R
mv ${resultname}_edgeR.tsv $exdir/r/r_result/${resultname}_edgeR.tsv

#merge_all
cd $exdir/tmp/
outdir=$exdir/comp_result

join -t "$(printf '\011')" -1 1 -2 1 <(cat $exdir/r/r_result/${resultname}_edgeR.tsv | sed -e '1d' | sort -k1 $exdir/r/r_result/${resultname}_edgeR.tsv | sed -e 's/"//g') \
<(cat $exdir/tpm/${resultname}_tpm.tsv | sed -e '1d' | sort -k1 $exdir/tpm/${resultname}_tpm.tsv) > tmp_file1

join -t "$(printf '\011')" -1 1 -2 1 tmp_file1 \
<(sort -k1 $annot) | sort -g -k5 | cut -f1,5,6,7,8,9,10,11,12 > tmp_file2
sed -n 1p $exdir/tpm/${resultname}_tpm.tsv | sed -e "s/Name//g" | cut -f2,3,4,5,6,7 > tmp_file3
cat tmp_file3 | awk '{print "id" "\t" "FDR" "\t" $1 "\t" $2 "\t"  $3 "\t"  $4 "\t"  $5 "\t"  $6 "\t" "annotation"}' > tmp_header
cat tmp_header tmp_file2 > $outdir/${resultname}.tsv
rm tmp_*


#calculatemean&se
cd $exdir/r/

cat $outdir/${resultname}.tsv | cut -f3,4,5 > g1
cat $outdir/${resultname}.tsv | cut -f6,7,8 > g2

rscript calmeanse.R

cat g1_mean | cut -f2 | sed -e 's/"x"/group1_mean/g' > g1_mean_value
cat g2_mean | cut -f2 | sed -e 's/"x"/group2_mean/g' > g2_mean_value
cat g1_se | cut -f2 | sed -e 's/"x"/group1_se/g' > g1_se_value
cat g2_se | cut -f2 | sed -e 's/"x"/group2_se/g' > g2_se_value

rm g1 g1_mean g1_se g2 g2_mean g2_se
mv g1_mean_value $exdir/tmp/
mv g2_mean_value $exdir/tmp/
mv g1_se_value $exdir/tmp/
mv g2_se_value $exdir/tmp/

cd $exdir/tmp/

cat $outdir/${resultname}.tsv | cut -f1,2,3,4,5,6,7,8 > split1
cat $outdir/${resultname}.tsv | cut -f9 > split2
paste split1 g1_mean_value g1_se_value g2_mean_value g2_se_value split2 > $outdir/${resultname}_comp.tsv
rm split1 split2 g1_mean_value g2_mean_value g1_se_value g2_se_value
rm $outdir/${resultname}.tsv
rm $exdir/tpm/ind/*
rm $exdir/rcount/ind/*
