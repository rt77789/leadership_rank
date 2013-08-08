
library(ggplot2)

d = read.table('../data/sp500_128_2012-12-21_2012-06-20.data', header=T)

#scol = c('AAPL.raw', 'AIZ.raw', 'STJ.raw', 'NEM.raw', 'PGR.raw', 'AIG.raw', 'BBBY.raw')
scol = c('AAPL.raw', 'AIZ.raw')

res = matrix(nrow=0, ncol=4)

for(i in 1:length(scol)) {
	
	tb = matrix(nrow=4, ncol=nrow(d))
	tb[1,] = rep(scol[i], nrow(d))
	tb[2,] = 1:nrow(d)
	tb[3,] = d[, scol[i]] / d[1, scol[i]]
	tb[4,] = rownames(d)
	
	res = rbind(res, t(tb))
}

res = data.frame(Stock = res[,1], x = as.numeric(res[,2]), y = as.numeric(res[,3]), date=res[,4])
#names(res) = c('Stock', 'x', 'y', 'date')

ggplot(res) + geom_point(aes(x=x, y=y, group=Stock, color=factor(Stock), shape=factor(Stock))) + geom_line(aes(x=x, y=y, group=Stock, color=factor(Stock))) + theme(axis.text.y = element_text(size = rel(1),  angle = 60), axis.text.x = element_text(size = rel(0.5), angle = 45), legend.position = "right", axis.title.x = element_blank(), 
		axis.title.y = element_blank())

