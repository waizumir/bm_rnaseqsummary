rowSE <- function( Matrix ){
  SE <- apply( X = Matrix, MARGIN = 1, FUN = function( Row ){ sd( Row )/sqrt( length( Row ) ) } )
  return( SE )
}

g1 <- read.table("g1", sep = "\t", header = T,)
g2 <- read.table("g2", sep = "\t", header = T,)


g1_mean <- rowMeans(g1)
g2_mean <- rowMeans(g2)
g1_se <- rowSE(Matrix = g1)
g2_se <- rowSE(Matrix = g2)

write.table(g1_mean, file = "g1_mean", sep = "\t")
write.table(g2_mean, file = "g2_mean", sep = "\t")
write.table(g1_se, file = "g1_se", sep = "\t")
write.table(g2_se, file = "g2_se", sep = "\t")
