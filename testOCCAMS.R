#OCCAMS
library(Matrix)
library(specL)


load("specLLibrary.RData")

tmp = getProteinPeptideTable(specLibrary)

prepareMatrix <- function(data){
  fprots = as.factor(data[,"prots"])
  prots = as.integer(fprots)
  fpeps = as.factor(data[,"peps"])
  peps = as.integer(fpeps)
  
  
  pepProt =sparseMatrix(peps, prots,x = 1 )
  dim(pepProt)
  
  sum(duplicated(levels(fpeps)))
  sum(duplicated(levels(fprots)))
  
  colnames(pepProt) <- levels(fprots)
  rownames(pepProt) <- levels(fpeps)
  
  dim(pepProt)
  return(pepProt)
}

pepProt <- prepareMatrix(tmp)

tmp=(cor(as.matrix(pepProt)))

dim(tmp)
summary(c(tmp))
