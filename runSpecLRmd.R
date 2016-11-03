#! /usr/bin/Rscript
#Sys.setenv(RSTUDIO_PANDOC="C:/Program Files/RStudio/bin/pandoc")
args <- commandArgs(TRUE)
print(args)
if (length(args)>=4){
  OUTPUTDIR <- args[1]
  FASTA_FILE <- args[2]
  MZ_ERROR <- as.numeric(args[3]) 
  MIN_IONS <- as.integer(args[4])
  MAX_IONS <- as.integer(args[5])
  BLIB_REDUNDANT <- args[6]
  BLIB_FILTERED <- args[7]
  cat("Set params OUTPUTDIR = ",OUTPUTDIR ,
      " FASTA_FILE = ",FASTA_FILE , " MZ_ERROR = ", MZ_ERROR,
      " MAX_IONS = ",MAX_IONS, " MIN_IONS = ", MIN_IONS," BLIB_REDUNDANT = ",
      BLIB_REDUNDANT, " BLIB_FILTERED = ",BLIB_FILTERED, "\n")
  rmarkdown::render("/scratch/wolski/generateSpecLibrary/specL.Rmd",output_format ="pdf_document", output_file = file.path(OUTPUTDIR, "SpecL.pdf"), clean=FALSE)
}else{
  print("/scratch/wolski/generateSpecLibrary/runSpecLRmd.R OUTPUTDIR FASTA_FILE MIN_IONS MAX_IONS BLIB_FILTERED BLIB_REDUNDANT")
  quit(status=1)
}

