## ------------------------------------------------------------------------
rm(list=ls())
library(specL)
packageVersion('specL')

## ------------------------------------------------------------------------
OUTPUTDIR = "."
WORKDIR = "."

FASTA_FILE <- "fgcz_10090_20140715.fasta"
SPECLIBRARYRDATA = file.path(OUTPUTDIR, "specLLibrary.RData")
SWATH_LIBRARY <- file.path(OUTPUTDIR,"assay_library.tsv")

TOPIONS <- 6

MZ_ERROR <- 0.05 # e.g for Q-Exactive
FRAGMENTIONMZRANGE <- c(300,1250)
FRAGMENTIONRANGE <- c(3,200)

ANNOTATEDRDATA <- file.path(WORKDIR,"Annotated.RData")
NON_REDUNDANT <- file.path(WORKDIR,"blib.blib.filtered.db")
REDUNDANT <- file.path(WORKDIR,"blib.blib.db")


## ---- echo=FALSE---------------------------------------------------------
fragmentIonFunctionUpTo3 <- function (b, y) {
  Hydrogen <- 1.007825
  Oxygen <- 15.994915
  Nitrogen <- 14.003074
  b1_ <- (b )
  y1_ <- (y )
  b2_ <- (b + Hydrogen) / 2
  y2_ <- (y + Hydrogen) / 2 
  return( cbind(b1_, y1_, b2_, y2_) )
}

## ------------------------------------------------------------------------
system.time( nonRedundantBlib <- read.bibliospec(NON_REDUNDANT) )
system.time( redundantBlib <- read.bibliospec(REDUNDANT) )
class(redundantBlib)


## ------------------------------------------------------------------------
system.time(annotatedBlib <- annotate.protein_id(nonRedundantBlib, file=FASTA_FILE))
save(annotatedBlib, file=ANNOTATEDRDATA, compress=TRUE)


## ------------------------------------------------------------------------

load(ANNOTATEDRDATA)
specLibrary <- genSwathIonLib(data = annotatedBlib,
  data.fit = redundantBlib,
  max.mZ.Da.error = MZ_ERROR,
  topN = TOPIONS,
  fragmentIonMzRange=FRAGMENTIONMZRANGE,
  fragmentIonRange=FRAGMENTIONRANGE,
  fragmentIonFUN = fragmentIonFunctionUpTo3)

save(specLibrary , file = SPECLIBRARYRDATA )


## ----echo=TRUE-----------------------------------------------------------
MySum <- summary(specLibrary)
specLibrary@ionlibrary[[1]]


## ------------------------------------------------------------------------
write.spectronaut(specLibrary,file=SWATH_LIBRARY)


