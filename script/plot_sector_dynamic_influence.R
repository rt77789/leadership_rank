

library(ggplot2)
library(vars)
library(fUnitRoots)
library(RColorBrewer)

source('util.R')

### Plot dynamic influence series w.r.t each sector.
plot_sector_dynamic_influence <- function() {
	d = read.table(get_filename_by_suffix('msector'), header = T, sep = ",")
	
	
	labels = levels(d[, 1])
	levels(d[, 1]) = 1:length(levels(d[, 1]))
	pos = seq(from = 1, to = length(labels), by = 10)
	d = subset(d, model == "mean_rank")
	
	cbPalette <- brewer.pal(10, "Paired")

	dev.new()
	ggplot(d) + geom_line(aes(x = date, y = value, group = factor(sector), color = factor(sector))) + scale_x_discrete(breaks = c(pos), 
	labels = c(labels[pos])) + facet_grid(sector ~ ., scales = "free") + theme(axis.text.y = element_text(size = rel(0.5), angle = 60), axis.text.x = element_text(size = rel(0.5), 
	angle = 45), legend.position = "right", axis.title.x = element_blank(), axis.title.y = element_blank()) + 
	scale_colour_manual(values = cbPalette) 
}

### Compute cross-correlation between each pair of sector's dynamic influence series.
cal_xcor_sector_dynamic_influence <- function() {
	from = as.numeric(config['start_stamp', 2])
	to = as.numeric(config['end_stamp', 2])
	msfile = paste('../data/', config['file_prefix', 2], from, '_', to, '.msector', sep='')
		
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
	smat
}

granger_test <- function(ts1, ts2) {
		### Selected lag under SC critieria.
		td = data.frame(x = ts1, y = ts2)
		slag = VARselect(td, lag.max = 14, type = "const")$selection
		print(slag)
		var.m = VAR(td, p = slag[3], type = "const")

		rc = causality(var.m, cause = "x")

		if (rc$Granger$p.value < 0.05) {
			1
		}

		rc = causality(var.m, cause = "y")
		if (rc$Granger$p.value < 0.05) {
			-1
		}
		0
	}



