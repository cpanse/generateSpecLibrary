#OCCAMS
library(Matrix)

tmp = read.csv("res2.csv")

head(tmp)

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

corProt=(cor(as.matrix(pepProt)))
dim(corProt)
image(corProt[1:100,1:100])

dim(pepProt)
xx<-sumRows(pepProt)




occam <- function(pepprot, ncolX = ncol(pepprot)){
  res<-vector(ncolX , mode="list")
  idxx <-NULL
  for(i in 1:ncolX) 
    {
    
    if(i %% 10 == 0){
      pepprot <- removeZeroRows(pepprot)
      drumm <<-pepprot
      idxxx <<- idxx
      cat("length(idxx)" , length(idxx), "\n")
      pepprot <- pepprot[,-idxx,drop=FALSE]
     
      idxx <-NULL
      cat("new dim" , dim(pepprot), "\n")
    }
    if(nrow(pepprot) == 0)
      break()
    oldtime <- Sys.time()
    pepsPerProt <- colSums(pepprot)
    idx <- which.max(pepsPerProt)
    if(length(idx) > 1){
      idx<-idx[1]
    }
    idxx <- c( idxx, idx )
    dele <- pepprot[,idx]
    tmpRes = list(prot = colnames(pepprot)[idx], peps = rownames(pepprot)[dele>0])
    res[[i]] <- tmpRes
    cat(i, " ", idx, " ", sum(dele), "\n")
    if(sum(dele) > 0){
      set = cbind(rep(dele > 0, ncol(pepprot)))
      #for(j in 1:ncol(pepprot)){
      pepprot[set] <- 0
      #}
    }
    newtime <- Sys.time()
    cat("time ",newtime - oldtime, "\n")
    
  }
  return(list(res = res))
}

occr <- occam(pepprot[,])

sum(occr$pepprot)
length(occr$res)
unique(occr$res[[1]]$peps)
