## ----prepareEnvLoadLibraries, echo=FALSE---------------------------------
R.Version()
library(specL)
packageVersion('specL')

## ----setparameters-------------------------------------------------------
if(!exists("OUTPUTDIR")){
  OUTPUTDIR = "res.12347"
  WORKDIR = "temp.12347"
  FASTA_FILE <- "fgcz_10090_20140715.fasta"
  MAX_IONS <- 6
  MIN_IONS <- 6
  BLIB_FILTERED <- "blib.blib.filtered.db"
  BLIB_REDUNDANT <- "blib.blib.db"
} else{
  print("NOW I am starting to rock!")
}

SPECLIBRARYRDATA = file.path(OUTPUTDIR, "specLLibrary.RData")
SWATH_LIBRARY <- file.path(OUTPUTDIR, "assay_library.tsv")
PEPPROTMAPPING <- file.path(OUTPUTDIR, "pepprot.tsv")

MZ_ERROR <- 0.05 # e.g for Q-Exactive
FRAGMENTIONMZRANGE <- c(300,1250)
FRAGMENTIONRANGE <- c(MIN_IONS,200)

ANNOTATEDRDATA <- file.path(WORKDIR,"Annotated.RData")
NON_REDUNDANT <- file.path(WORKDIR,BLIB_FILTERED)
REDUNDANT <- file.path(WORKDIR,BLIB_REDUNDANT)

cat("Set params SPECLIBRARYRDATA = ",SPECLIBRARYRDATA , "\n",
    " SWATH_LIBRARY = ", SWATH_LIBRARY, "\n", 
    " PEPPROTMAPPING = ",PEPPROTMAPPING , "\n",
    " MZ_ERROR = ",MZ_ERROR, " FRAGMENTIONMZRANGE = ", FRAGMENTIONMZRANGE, "\n",
    " FRAGMENTIONRANGE = ",FRAGMENTIONRANGE, "\n",
    " ANNOTATEDRDATA = ",ANNOTATEDRDATA, "\n",
    " NON_REDUNDANT = ",NON_REDUNDANT , "\n",
    " REDUNDANT = ",REDUNDANT, "\n"   )


## ----defineFragmentFunction----------------------------------------------
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


## ----readDatabases, eval=TRUE, echo=FALSE--------------------------------
system.time( nonRedundantBlib <- read.bibliospec(NON_REDUNDANT) )
system.time( redundantBlib <- read.bibliospec(REDUNDANT) )
save(redundantBlib,file=file.path(WORKDIR,"redundant.Rdata"))
save(nonRedundantBlib,file=file.path(WORKDIR,"nonredundant.Rdata"))


## ----generateLibrary,echo=FALSE------------------------------------------
load(file.path(WORKDIR,"redundant.Rdata"))
load(file.path(WORKDIR,"nonredundant.Rdata"))

specLibrary <- genSwathIonLib(data = nonRedundantBlib,
  data.fit = redundantBlib,
  max.mZ.Da.error = MZ_ERROR,
  topN = MAX_IONS,
  fragmentIonMzRange = FRAGMENTIONMZRANGE,
  fragmentIonRange = FRAGMENTIONRANGE,
  fragmentIonFUN = fragmentIonFunctionUpTo3)
save(specLibrary , file = SPECLIBRARYRDATA )


## ----printSummary,echo=TRUE----------------------------------------------
MySum <- summary(specLibrary)


## ----getPeptideProt------------------------------------------------------
protpep = getProteinPeptideTable(specLibrary)


## ----prozor, echo=FALSE, message=FALSE-----------------------------------

library(prozor)
fasta = read.fasta(file = FASTA_FILE, as.string = TRUE, seqtype="AA")
protpepAnnot = annotatePeptides(protpep,fasta)
write.table(protpepAnnot,file=PEPPROTMAPPING,quote = FALSE, row.names = FALSE)
pepProtMatrix = prepareMatrix(protpepAnnot)

protPepAssingments = greedy(pepProtMatrix)


for(i in 1:length(specLibrary@ionlibrary)){
  specl <- specLibrary@ionlibrary[[i]]
  id <- paste(specl@peptideModSeq, specl@prec_z, sep="." )
  tmp = protPepAssingments[[id]]
  if(!is.null(tmp)){
    specLibrary@ionlibrary[[i]]@proteinInformation = tmp
  }
}


## ----writeSpecnaut-------------------------------------------------------
write.spectronaut(specLibrary,file=SWATH_LIBRARY)


