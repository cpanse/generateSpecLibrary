#! /usr/bin/Rscript
Sys.setenv(RSTUDIO_PANDOC="C:/Program Files/RStudio/bin/pandoc")
args <- commandArgs(TRUE)
print(args)
if (length(args)>=4){
  OUTPUTDIR <- args[1]
  WORKDIR <- args[2]
  FASTA_FILE <- args[3]
  MZ_ERROR <- as.numeric(args[4]) 
  MIN_IONS <- as.integer(args[5])
  MAX_IONS <- as.integer(args[6])
  BLIB_REDUNDANT <- args[7]
  BLIB_FILTERED <- args[8]
  cat("Set params OUTPUTDIR = ",OUTPUTDIR ,
      " WORKDIR = ", WORKDIR,
      " FASTA_FILE = ",FASTA_FILE , " MZ_ERROR = ", MZ_ERROR,
      " MAX_IONS = ",MAX_IONS, " MIN_IONS = ", MIN_IONS," BLIB_REDUNDANT = ",
      BLIB_REDUNDANT, " BLIB_FILTERED = ",BLIB_FILTERED, "\n")
  rmarkdown::render("C:/users/wolski/prog/generateSpecLibrary/specL.Rmd",output_format ="pdf_document", output_file = file.path(OUTPUTDIR, "SpecL.pdf"), clean=FALSE)
}else{
  print("/scratch/wolski/generateSpecLibrary/runSpecLRmd.R OUTPUTDIR INPUTDIR FASTA_FILE MIN_IONS MAX_IONS BLIB_FILTERED BLIB_REDUNDANT")
  quit(status=1)
}

