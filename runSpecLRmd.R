#! /usr/bin/env Rscript
args <- commandArgs(TRUE)

if (length(args)>=4){
  library(knitr)
  OUTPUTDIR <- args[1]
  WORKDIR <- args[2]
  FASTA_FILE <- args[3]
  MIN_IONS <- args[4]
  MAX_IONS <- args[5]
  
  BLIB_REDUNDANT <- args[6]
  BLIB_FILTERED <- args[7]
  cat("Set params OUTPUTDIR = ",OUTPUTDIR ,
      " WORKDIR = ", WORKDIR,
      " FASTA_FILE = ",FASTA_FILE ,
      " MAX_IONS = ",MAX_IONS, " MIN_IONS = ", MIN_IONS," BLIB_REDUNDANT = ",
      BLIB_REDUNDANT, " BLIB_FILTERED = ",BLIB_FILTERED, "\n"   )
  
  knit2pdf("specL.Rmd",output=file.path(OUTPUTDIR,"specL.pdf"))

}else{
  print("runSpecLRmd.R OUTPUTDIR INPUTDIR FASTA_FILE MIN_IONS MAX_IONS BLIB_FILTERED BLIB_REDUNDANT")
}


