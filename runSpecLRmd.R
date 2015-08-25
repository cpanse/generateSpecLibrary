#! /usr/bin/env Rscript
args <- commandArgs(TRUE)
print(args)
if (length(args)>=4){
  library(knitr)
  OUTPUTDIR <- args[1]
  WORKDIR <- args[2]
  FASTA_FILE <- args[3]
  MAX_IONS <- args[4]
  MIN_IONS <- args[5]
  cat("Set params ",OUTPUTDIR , " ", WORKDIR, " ",FASTA_FILE , " ",MAX_IONS, " ", MIN_IONS, "\n"   )
  knit2pdf("specL.Rmd")
  
}else{
  print("runSpecLRmd.R OUTPUTDIR WORKDIR FASTA_FILE TOP_IONS MIN_IONS")
}


