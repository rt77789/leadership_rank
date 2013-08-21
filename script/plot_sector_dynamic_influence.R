

library('ggplot2')
library('vars')
library('fUnitRoots')
library('RColorBrewer')
library('corrplot')

source('util.R')

### Plot dynamic influence series w.r.t each sector.
plot_sector_dynamic_influence <- function() {
	d = read.table(get_filename_by_suffix('msector'), header = T, sep = ",")
	
	labels = levels(d[, 1])
	levels(d[, 1]) = 1:length(levels(d[, 1]))
	pos = seq(from = 1, to = length(labels), by = 10)
	d = subset(d, model == "mean_rank")
	
	cbPalette <- brewer.pal(10, "Paired")

	
	p = ggplot(d) + 
	geom_line(aes(x = date, y = value, group = factor(sector), color = factor(sector)), size=0.3) + 
	scale_x_discrete(breaks = c(pos), labels = c(labels[pos])) + 
	facet_grid(sector ~ ., scales = "free") + 
	theme(axis.text.y = element_blank(), 
	axis.ticks.y = element_blank(), 
	axis.text.x = element_text(size = rel(0.5), angle = 90), 
	axis.title.x = element_blank(), 
	axis.title.y = element_blank(), 
	legend.position="none", 
	strip.text.y = element_text(size = 4, colour = "black", angle = 0),
	plot.title = element_text(size = 7)) + 
	scale_colour_manual(values = cbPalette) +xlab("Time") +
  	ylab("") +
  	ggtitle("Dynamic Leadership Score of each sector.")

	
	for(suf in c('.eps', '.pdf')) {
		ggsave(p, file=paste(config['pics_dir', 2], 'sector_dynamic_influence_', config['start_stamp', 2], '_', config['end_stamp', 2], suf, sep=''), width=1, height=1.6, scale=4)
	}
	dev.new() 
	p
}

plot_sp500_sector_index <- function() {
	d = read.table(get_filename_by_suffix('msector'), header = T, sep = ",")
	
	sector.index = sapply(levels(d$sector), function(x) {norm_vector(cal_sp500_sector_index(x, 'cap'))})
	sector.index = frame_convert(sector.index)
	
	sp500.index = norm_vector(cal_sp500_index())
	
	cbPalette <- brewer.pal(10, "Paired")
	
	#ggplot(sector.index) + geom_line(aes(x = x, y = y, group = factor(g), color = factor(g)))
	p = ggplot(sector.index) + 
	geom_line(aes(x = x, y = y, group = factor(g), color = factor(g)), size=0.3) + 
	geom_line(data = data.frame(x = sector.index$x, y = sp500.index), aes(x=x, y = y), color = 'black', linetype='solid', size=0.3) + 
	facet_grid(g ~ ., scales = "free") + 
	theme(axis.text.y = element_blank(), 
	axis.ticks.y = element_blank(),
	axis.text.x = element_text(size = rel(0.5), angle = 90), 
	axis.title.x = element_blank(), 
	axis.title.y = element_blank(), 
	legend.position="none", 
	strip.text.y = element_text(size = 4, colour = "black", angle = 0),
	plot.title = element_text(size = 7)) + 
	scale_colour_manual(values = cbPalette) +
	xlab("Time") +
	ylab("") +
	ggtitle("Sector Index in S&P 500 companies (Weighted Average Market Capitalization).")
  	
  	for(suf in c('.eps', '.pdf')) {
		ggsave(p, file=paste(config['pics_dir', 2], config['file_prefix', 2], 'sector_index_', config['start_stamp', 2], '_', config['end_stamp', 2], suf, sep=''), width=1, height=1.6, scale=4)
	}
  	dev.new()
  	p
}

### Compute cross-correlation between each pair of sector's dynamic influence series.
cal_xcor_sector_dynamic_influence <- function() {
	from = as.numeric(config['start_stamp', 2])
	to = as.numeric(config['end_stamp', 2])
	msfile = paste(config['data_dir', 2], config['file_prefix', 2], from, '_', to, '.msector', sep='')
		
	d = read.table(msfile, header = T, sep = ",")

	labels = levels(d[, 1])
	levels(d[, 1]) = 1:length(levels(d[, 1]))
	pos = seq(from = 1, to = length(labels), by = 10)
	d = subset(d, model == "mean_rank")
	#d = subset(d, sector=='sum_rank')
	
	d2 = lapply(levels(d$sector), function(x) {
		r = subset(d, sector == x)
		#r$value = c(0, (r$value[-1] - r$value[-length(r$value)]) / r$value[-length(r$value)])
		#a = adfTest(r$value)
#print(attr(a, "test")$p.value)
r
	})

	smat = matrix(0, length(d2), length(d2))

	rownames(smat) = levels(d$sector)
	colnames(smat) = levels(d$sector)
	lags = smat

	
	for (i in 1:length(d2)) {
		for (j in 1:length(d2)) {
			if (i != j) {
				res = ccf(d2[[i]]$value, d2[[j]]$value, type = "correlation", lag.max = 30, plot = F)
				pos = which(res$acf == max(res$acf))[1]

				if (res$lag[pos] < 0 && res$acf[pos] > 0) {
					### i lead j, and pagerank works at this style.
					### Make sure the correlation is positive and bigger than the threshold.
					smat[i, j] = res$acf[pos]
					lags[i, j] = pos - length(d2[[j]]$value)/2 - 1
				}
				# rg = granger_test(d2[[i]]$value, d2[[j]]$value)
				# if(rg == 1) {
# smat[i, j] = 1
# }
# else {
# if(rg == -1) {
# smat[j, i] = 1
# }	
# } 

			}
		}
	}
	pdf(file=paste(config['pics_dir', 2], config['file_prefix', 2], 'sector_dynamic_influence_correlation_', config['start_stamp', 2], '_', config['end_stamp', 2], '.pdf', sep=''), width=1.8*4, height=1.8*4)
	corrplot(smat, addCoef.col='black', addCoef.cex = 0.5, tl.cex=0.7, tl.srt=30, tl.col='black', cl.lim=c(0, 1))
	dev.off()
	#print(smat)
	smat
}


