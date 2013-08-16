
library(ggplot2)
library(RColorBrewer)
libarry(pracma)

source("util.R")

plot_stock_dynamic_influence <- function(ticker = NULL) {

	set.seed(1)
	
	d = read.table(get_filename_by_suffix('cevolute'))
	res = matrix(nrow = 0, ncol = 4)
	#cbPalette <- brewer.pal(10, "Paired")
	indx = c(1, 2, 3)

	if (!is.null(ticker)) {
		indx = which(colnames(d) %in% ticker)
	}

	for (i in indx) {
		tb = matrix(nrow = 4, ncol = nrow(d))
		tb[1, ] = rep(colnames(d)[i], nrow(d))
		tb[2, ] = 1:nrow(d)
		tb[3, ] = d[, i]
		tb[4, ] = rownames(d)

		res = rbind(res, t(tb))
	}

	res = data.frame(Stock = res[, 1], x = as.numeric(res[, 2]), y = as.numeric(res[, 3]), date = res[, 4])
	#names(res) = c('Stock', 'x', 'y', 'date')
	
	labels = levels(res$date)
	levels(res$date) = 1:length(levels(res$date))
	pos = seq(from = 1, to = length(labels), by = 10)

	ggplot(res) + 
		#geom_point(aes(x = date, y = y, group = Stock, color = factor(Stock), shape = factor(Stock))) + 
		geom_line(aes(x = date, y = y, group = Stock, color = factor(Stock))) + scale_x_discrete(breaks = c(pos), 
		labels = c(labels[pos])) + 
		theme(axis.text.y = element_text(size = rel(1), angle = 60), axis.text.x = element_text(size = rel(0.5), 
		angle = 45), legend.position = "right", axis.title.x = element_blank(), axis.title.y = element_blank()) # + scale_colour_manual(values=cbPalette)


}
