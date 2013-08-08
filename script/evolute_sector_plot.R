

library(ggplot2)
require(RColorBrewer)

d = read.table('../data/sp500_128_2009-02-09_2012-12-21.msector', header=T, sep=',')

d = subset(d, model==2)

cbPalette <- brewer.pal( 10 , "Paired" )

ggplot(d) + geom_line(aes(x=date, y=value, group=factor(sector), color=factor(sector))) + geom_point(aes(x=date, y=value, group=factor(sector), color=factor(sector)), shape=1, alpha=1) + theme(axis.text.y = element_text(size = rel(1),  angle = 60), axis.text.x = element_text(size = rel(0.5), angle = 45), legend.position = "right", axis.title.x = element_blank(), axis.title.y = element_blank()) + scale_colour_manual(values=cbPalette)
