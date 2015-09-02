#! /usr/bin/env Rscript

knit2pdf("specL.Rmd", output=file.path(OUTPUTDIR,"specL.pdf"),compiler="texi2pdf" )
  

