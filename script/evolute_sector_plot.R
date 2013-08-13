

library(ggplot2)
require(RColorBrewer)

d = read.table('../data/sp100_128_1995-02-15_2012-12-21_step_128/sp100_128_1995-02-15_2012-12-21.msector', header=T, sep=',')


labels = levels(d[,1])
levels(d[,1]) = 1:length(levels(d[,1]))
pos = seq(from=1, to=length(labels), by=10)
d = subset(d, model=='sum_crank')


cbPalette <- brewer.pal(10 , "Paired" )

ggplot(d) + geom_line(aes(x=date, y=value, group=factor(sector), color=factor(sector))) +  + scale_x_discrete(breaks=c(pos), labels=c(labels[pos])) + theme(axis.text.y = element_text(size = rel(1),  angle = 60), axis.text.x = element_text(size = rel(0.5), angle = 45), legend.position = "right", axis.title.x = element_blank(), axis.title.y = element_blank()) + scale_colour_manual(values=cbPalette)
