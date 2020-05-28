#This script was created, and files were all downloaded on May-22-2020

#R script to run after downloading the required files that are organized by Glomeromycotan class

#adapted from: https://github.com/sghignone/R.Qiime_MaarjAM/blob/master/code/makeMaarjAMDB.R

BiocManager::install("gdata")
library("gdata")
library("Biostrings")

##PART ONE##
#PREPARATION OF THE ID to TAXONOMY FILE
#LOAD THE FILES 
archaeo <- read.xls("export_biogeo_archaeo.xls", sheet = 1, fileEncoding="latin1", stringsAsFactors=FALSE)
paraglom <- read.xls("export_biogeo_paraglom.xls", sheet = 1, fileEncoding="latin1", stringsAsFactors=FALSE)
glomero <- read.xls("export_biogeo_glomero.xls", sheet = 1, fileEncoding="latin1", stringsAsFactors=FALSE)

#COMBINE THE DATASETS
all <- rbind(paraglom,archaeo,glomero) #For production
dim(all)

#Check for duplicated entries and remove them
all[duplicated(all$GenBank.accession.number), ][,2]
all <- all[!duplicated(all$GenBank.accession.number), ]
dim(all)

# Skip  YYY00000 entries
all <- all[all$GenBank.accession.number != "YYY00000", ]
dim(all)

#SORT DATASET BY GenBank.accession.number
all.ordered <- all[order(as.character(all[,"GenBank.accession.number"])),]
dim(all.ordered)
head(all.ordered)


#Take GenBank.accession.number, extract taxonomy, format  
all.ordered_taxo <- data.frame()
for (i in 1:nrow(all.ordered)){
  if (all.ordered$VTX[i] != ""){
    all.ordered_taxo[i, 1] <- all.ordered[i, "GenBank.accession.number"] 
    all.ordered_taxo[i, 2] <- paste0("Fungi;Glomeromycota;",
                                     all.ordered[i, "Fungal.class"],
                                     ";",
                                     all.ordered[i, "Fungal.order"],
                                     ";",
                                     all.ordered[i, "Fungal.family"],
                                     ";",
                                     all.ordered[i, "Fungal.genus"],
                                     ";", #can run this as "_" if need be
                                     all.ordered[i, "Fungal.species"],
                                     "_",
                                     all.ordered[i, "VTX"]
    )
  } else {
    all.ordered_taxo[i, 1] <- all.ordered[i, "GenBank.accession.number"] 
    all.ordered_taxo[i, 2] <- paste0("Fungi;Glomeromycota;",
                                     all.ordered[i, "Fungal.class"],
                                     ";",
                                     all.ordered[i, "Fungal.order"],
                                     ";",
                                     all.ordered[i, "Fungal.family"],
                                     ";",
                                     all.ordered[i, "Fungal.genus"],
                                     "_",
                                     all.ordered[i, "Fungal.species"]
    )
  }
}

dim(all.ordered_taxo)
str(all.ordered_taxo)

# Save table to file
write.table(all.ordered_taxo, "maarjAM_qiime_taxonomy.txt", sep = "\t",
            row.names = FALSE, col.names = FALSE, quote = FALSE)

#qiime import command (for command line):
qiime tools import \
--type 'FeatureData[Taxonomy]' \
--input-format HeaderlessTSVTaxonomyFormat \
--input-path maarjam/maarjAM_qiime_taxonomy.txt \
--output-path ref-taxonomy_maarjAM.qza

##PART TWO##
#PREPARATION OF THE FASTA FILE
paraglom.seq <- readBStringSet("MaarjAM_seqs_paraglomeromycetes.txt","fasta")
names(paraglom.seq) <- gsub("gb\\|", "", names(paraglom.seq))
archaeo.seq <- readBStringSet("MaarjAM_seqs_archaeosporomycetes.txt", "fasta")
names(archaeo.seq) <- gsub("gb\\|", "", names(archaeo.seq))
glomero.seq <- readBStringSet("MaarjAM_seqs_glomeromycetes.txt", "fasta")
names(glomero.seq) <- gsub("gb\\|", "", names(glomero.seq))

all.seq <- append(paraglom.seq, c(archaeo.seq, glomero.seq), after=length(paraglom.seq))
head(names(all.seq))

#filter out  YYY00000
all.seq <- all.seq[names(all.seq) != "YYY00000"]

#order
all.ordered.seq <- all.seq[order(as.character((names(all.seq))))]

#save
writeXStringSet(all.ordered.seq, "maarjAM_all.fasta", format="fasta")


#####
### IMPORTANT 
#####
##

#before importing into QIIME you must IN COMMAND LINE:

#make everything uppercase
#remove all non IUPAC characters
#remove any duplicates
#remove all text but the accession numbers for fasta headers
awk '/^>/ {print($0)}; /^[^>]/ {print(toupper($0))}' maarjAM_all.fasta |\
sed -e '/^[^>]/s/[^ATGCatgc]/N/g'|\
sed 's/_.*//' |\
awk '/^>/{f=!d[$1];d[$1]=1}f' > maarjAM_all_clean.fasta

#qiime import command:
qiime tools import \
--type 'FeatureData[Sequence]' \
--input-path maarjAM_all_clean.fasta \
--output-path maarjAM.qza


#PREPARATION OF THE MaarjAM-specific VIRTUAL TAXA FASTA FILE
vt.seq <- readBStringSet("/Users/danielrevillini/Documents/ABS_gap/QIIME/maarjam/vt_types_fasta_from_05-06-2019.txt", "fasta") # for production
names(vt.seq) <- gsub("gb\\|(.*)_(.*)", "\\1 \\2", names(vt.seq))

#save
writeXStringSet(vt.seq, "maarjAM.vt.fasta", format="fasta")
#likely have to run these commands on this fasta file as well:  
#make everything uppercase
#remove all non IUPAC characters
#remove any duplicates
#remove all text but the accession numbers for fasta headers
awk '/^>/ {print($0)}; /^[^>]/ {print(toupper($0))}' maarjAM.vt.fasta |\
sed -e '/^[^>]/s/[^ATGCatgc]/N/g'|\
sed 's/_.*//' |\
awk '/^>/{f=!d[$1];d[$1]=1}f' > maarjAM.vt_clean.fasta

