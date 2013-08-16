

library(ggplot2)
library(RColorBrewer)

source("util.R")

plot_market_dynamic_influence <- function() {
	topk = 3
	
	d = read.table(get_filename_by_suffix('msector'), header = T, sep = ",")

	labels = levels(d[, 1])
	levels(d[, 1]) = 1:length(levels(d[, 1]))
	pos = seq(from = 1, to = length(labels), by = 5)
	## sum_crank/mean_crank/sum_rank/mean_rank
	d = subset(d, model == "mean_crank")

	nd = data.frame(date = 1:length(levels(d$date)), value = sapply(levels(d$date), function(x) {
		mean(d[which(x == d[, 1]), 3])
	}))
	sp500.index = cal_sp500_index()
	leader.index = cal_leader_index(topk)
	
	len = length(sp500.index) - length(nd$value)
	nd = c(rep(nd$value[1], len), nd$value)

	nd = frame_convert(data.frame(sp500 = norm_vector(sp500.index), leader = norm_vector(leader.index), market = norm_vector(nd)))

	#cbPalette <- brewer.pal(10, "Paired")

	dev.new()
	ggplot(nd) + geom_path(aes(x = x, y = y, group = factor(g), color=factor(g))) + scale_x_discrete(breaks = c(pos), labels = c(labels[pos])) + 
		theme(axis.text.y = element_text(size = rel(1), angle = 60), axis.text.x = element_text(size = rel(0.5), 
			angle = 45), legend.position = "right", axis.title.x = element_blank(), axis.title.y = element_blank())# + 
	#	scale_colour_manual(values = cbPalette)

}