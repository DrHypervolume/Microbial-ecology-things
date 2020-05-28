# MaarjAM to QIIME2

This script and associated files use downloads from https://maarjam.botany.ut.ee/ to create an AM fungal fasta file and associated AM fungal taxonomy file to be uploaded into QIIME2 and used to BLAST targeted SSU amplicons using AM fungal-specific primers. 

You can: 

1) use the R script after downloading your own MaarjAM files to process for import into QIIME.
2) download my maarjam_dls folder and use the script to process those. 
3) download my 'clean' .qza (qiime2) files and simply run your consensus blast on your own denoised rep-seqs.qza file.
4) use the .sh script with qiime commands to run through your own analyses with data that has already been processed through deblur or dada2.

I also uploaded all qiime commands from taxonomy imports -> barplots that use a two-step process where SSU seqs are first identified with MaarjAM, and then the unassigned sequences are classified with SILVA 18S (uploaded silva v132 taxonomy and sequences files here). Finally only fungi (3__Fungi,Fungi) are filtered and visualized. 
