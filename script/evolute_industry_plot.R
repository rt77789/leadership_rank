

library(ggplot2)
require(RColorBrewer)

d = read.table('../data/sp500_128_1995-09-11_2012-12-21.mindustry', header=T, sep=',')

levels(d[,3])[1:10]

labels = levels(d[,1])
levels(d[,1]) = 1:length(levels(d[,1]))
pos = seq(from=1, to=length(labels), by=2)
d = subset(d, model=='mean_crank')

ggplot(d) + geom_line(aes(x=date, y=value, group=factor(industry), color=factor(industry))) + geom_point(aes(x=date, y=value, group=factor(industry), color=factor(industry)), shape=1, alpha=1) + scale_x_discrete(breaks=c(pos), labels=c(labels[pos])) + theme(axis.text.y = element_text(size = rel(1),  angle = 60), axis.text.x = element_text(size = rel(0.5), angle = 45), legend.position = "right", axis.title.x = element_blank(), axis.title.y = element_blank()) 

disp_date_model <- function(d, date, model) {
	d[which(d[,4] == model & d[,1] == date)[order(d[which(d[,4] == model & d[,1] == date), 3], decreasing=T)],]
}