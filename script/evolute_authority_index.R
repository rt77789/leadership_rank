

library(ggplot2)
require(RColorBrewer)

d = read.table('../data/sp500_128_1995-09-11_2012-12-21.msector', header=T, sep=',')

d = subset(d, model=='sum_crank')

nd = data.frame(date = 1:length(levels(d$date)), value=sapply(levels(d$date), function(x) { mean(d[which(x == d[,1]), 3]) }))

cbPalette <- brewer.pal(10 , "Paired" )

ggplot(nd) + geom_path(aes(x = date, y = value)) + scale_x_discrete(breaks=c(pos), labels=c(labels[pos]))+ theme(axis.text.y = element_text(size = rel(1),  angle = 60), axis.text.x = element_text(size = rel(0.5), angle = 45), legend.position = "right", axis.title.x = element_blank(), axis.title.y = element_blank()) + scale_colour_manual(values=cbPalette)

