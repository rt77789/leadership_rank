
library(ggplot2)
d = read.table('../data/sp500_128_2009-02-09_2012-12-21.evolute')

res = matrix(nrow=0, ncol=4)

for(i in 1:6) {
	tb = matrix(nrow=4, ncol=nrow(d))
	tb[1,] = rep(colnames(d)[i], nrow(d))
	tb[2,] = 1:nrow(d)
	tb[3,] = d[,i]
	tb[4,] = rownames(d)
	
	res = rbind(res, t(tb))
}
res = data.frame(Stock = res[,1], x = as.numeric(res[,2]), y = as.numeric(res[,3]), date=res[,4])
#names(res) = c('Stock', 'x', 'y', 'date')

ggplot(res) + geom_point(aes(x=date, y=y, group=Stock, color=factor(Stock), shape=factor(Stock))) + geom_line(aes(x=date, y=y, group=Stock, color=factor(Stock))) + theme(axis.text.y = element_text(size = rel(1),  angle = 60), axis.text.x = element_text(size = rel(0.7), angle = 45), legend.position = "right", axis.title.x = element_blank(), 
		axis.title.y = element_blank())

