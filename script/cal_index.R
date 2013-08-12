
library(ggplot2)
library('pracma')

cal_index <- function(rr, rbase, d) {
		set.seed(1)
	rr = subset(rr, stock %in% intersect(rr[,1], colnames(d)))
	rbase = subset(rbase, stock %in% intersect(rbase[,1], colnames(d)))
	
	nd = apply(rr, 1, function(x) {
		d[, x[1]] * as.numeric(x[3])/sum(as.numeric(rr[, 3]))
	})
	#ts.plot(apply(nd, 1, sum))
	
	nd2 = apply(rbase, 1, function(x) {
		d[, x[1]] * as.numeric(x[2])/sum(as.numeric(rbase[, 2]))
	})
	
	nd3 = apply(rbase, 1, function(x) {
		d[, x[1]] * as.numeric(x[3])/sum(as.numeric(rbase[, 3]))
	})

	pos4 = randperm(nrow(rr), nrow(rbase))
	
	nd4 = apply(rr[pos4, ], 1, function(x) {
		d[, x[1]] * as.numeric(x[3])/sum(as.numeric(rr[pos4, 3]))
	})
	
	#ts.plot(apply(nd, 1, sum), apply(nd2, 1, sum))
	
	nd = apply(nd, 1, sum)
	nd2 = apply(nd2, 1, sum)
	nd3 = apply(nd3, 1, sum)
	nd4 = apply(nd4, 1, sum)
	
	nd = nd / nd[1]
	nd2 = nd2 / nd2[1]
	nd3 = nd3 / nd3[1]
	nd4 = nd4 / nd4[1]
	
	#nd = (nd[-1] - nd[-length(nd)])/nd[-length(nd)]
	#nd2 = (nd2[-1] - nd2[-length(nd2)])/nd2[-length(nd2)]
	
	
	data = data.frame(x = rep(1:length(nd), 4), y = c(nd, nd2, nd3, nd4), g = factor(c( rep(1, length(nd)), rep(2, length(nd2)), rep(3, length(nd3)), rep(4, length(nd3)))))

	levels(data$g) = c('S&P 500', 'Leadership (20)', 'top 20 cap', 'random')
	#print(data$g)
	ggplot(data) + geom_line(aes(x, y, group = g, color= factor(g))) + geom_point(aes(x, y, group = g, color= factor(g), shape=factor(g)))

}
