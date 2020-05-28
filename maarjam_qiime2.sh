#### MAARJAM
#two-step process of OTU/ASV picking with SSU data - MaarjAM first then SILVA 18S

#import seqs from maarjAM
qiime tools import \
	--type 'FeatureData[Sequence]' \
	--input-path maarjam/maarjAM_all_clean.fasta \
	--output-path maarjAM.qza

#import matching taxonomy file
qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --input-format HeaderlessTSVTaxonomyFormat \
  --input-path maarjam/maarjAM_qiime_taxonomy.txt \
  --output-path ref-taxonomy_maarjAM.qza

#classify with consensus BLAST
qiime feature-classifier classify-consensus-blast \
	--i-reference-reads maarjAM.qza \
	--i-reference-taxonomy ref-taxonomy_maarjAM.qza \
	--p-perc-identity 0.99 \
	--i-query se_rep-seqs-dada2.qza \ #insert your rep-seqs file here, in this case single-end using dada2
	--o-classification taxonomy_maarjAM.qza

#visualize taxonomy output
qiime metadata tabulate \
  --m-input-file taxonomy_maarjAM.qza \
  --o-visualization taxonomy_maarjAM.qzv

#create barplots with metadata file
qiime taxa barplot \
  --i-table dan-table.qza \ #this is your original --o-table from qiime dada2 denoise-single\
  --i-taxonomy taxonomy_maarjAM.qza \
  --m-metadata-file map_SSU.txt \
  --o-visualization taxa-bar-plots_maarjAM.qzv

#need to keep all the 'Unassigned' seqs from the original rep-seqs file then classify with SILVA
qiime taxa filter-seqs \
  --i-sequences se_rep-seqs-dada2.qza \
  --i-taxonomy taxonomy_maarjAM.qza \
  --p-include Unassigned \
  --o-filtered-sequences maarjAM_unassigned_rep-seqs.qza

qiime feature-table tabulate-seqs \
  --i-data maarjAM_unassigned_rep-seqs.qza \
  --o-visualization maarjAM_unassigned_rep-seqs.qzv
  
#### SILVA 
###
#import the rep seqs from SILVA 132 99% 18S only
qiime tools import \
	--type 'FeatureData[Sequence]' \
	--input-path silva_132_99_18S.fasta \ 
	--output-path silva_132_99_18S.qza
	
#import matching taxonomy file
qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --input-format HeaderlessTSVTaxonomyFormat \
  --input-path majority_taxonomy_7_levels.txt \
  --output-path ref-taxonomy_silva.qza
  
#train classifier on full ref seqs
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads silva_132_99_18S.qza \
  --i-reference-taxonomy ref-taxonomy_silva.qza \
  --o-classifier silva_132_99_18S_classifier.qza

#####
###use classifier to id taxonomy from unassigned MaarjAM rep-seqs (from above)
qiime feature-classifier classify-sklearn \
  --i-classifier silva_132_99_18S_classifier.qza \
  --i-reads maarjAM_unassigned_rep-seqs.qza \
  --o-classification taxonomy_silva.qza
  
#visualize taxonomy output
qiime metadata tabulate \
  --m-input-file taxonomy_silva.qza \
  --o-visualization taxonomy_silva.qzv
  
####
##		MERGE SILVA and then MaarjAM taxonomy files (order is important here)
qiime feature-table merge-taxa \
	--i-data taxonomy_silva.qza \
	--i-data taxonomy_maarjAM.qza \
	--o-merged-data taxonomy_silva-maarjAM_merge.qza

#create barplots with metadata file
qiime taxa barplot \
  --i-table dan-table.qza \ 
  --i-taxonomy taxonomy_silva-maarjAM_merge.qza \
  --m-metadata-file map_SSU.txt \
  --o-visualization taxa-bar-plots_silva-maarjAM_merge.qzv

####  
#filter a feature table with only SILVA + maarjAM fungi
qiime taxa filter-table \
  --i-table dan-table.qza \
  --i-taxonomy taxonomy_silva-maarjAM_merge.qza \
  --p-include 3__Fungi,Fungi \
  --o-filtered-table fungi_only_table.qza

#summarize fungi table
qiime feature-table summarize \
  --i-table fungi_only_table.qza \
  --o-visualization fungi_only_table.qzv \
  --m-sample-metadata-file map_SSU.txt

#create fungi barplots
qiime taxa barplot \
  --i-table fungi_only_table.qza \
  --i-taxonomy taxonomy_silva-maarjAM_merge.qza \
  --m-metadata-file map_SSU.txt \
  --o-visualization taxa-bar-plots_fungi_only.qzv
