library(edgeR)

count <- read.table("rcounttable_rcount.tsv", sep = "\t", header = T, row.names = 1)

count <- as.matrix(count)

group <- factor(c("a", "a", "a", "b", "b", "b"))

d <- DGEList(counts = count, group = group)

d <- calcNormFactors(d)
d <- estimateCommonDisp(d)
d <- estimateTagwiseDisp(d)

result <- exactTest(d)

table <- as.data.frame(topTags(result, n = nrow(count)))
write.table(table, file = "rcounttable_edgeR.tsv", col.names = T, row.names = T, sep = "\t")
