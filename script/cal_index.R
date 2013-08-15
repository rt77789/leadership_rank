
library(ggplot2)
library('pracma')

cal_index <- function() {
		# ggplot(res) + geom_line(aes(x, y, group = factor(stock), color= factor(stock))) + geom_point(aes(x, y, group = factor(stock), color= factor(stock), shape=factor(stock)))
		
		leader.index = cal_leader_index(0)
		sp500.index = cal_sp500_index('../data/sp500_1374586200_1374609600.raw', '../resource/sp500_market_cap.table')
		
		leader.index = (leader.index - mean(leader.index)) / sd(leader.index)
		sp500.index = (sp500.index - mean(sp500.index)) / sd(sp500.index)
		
		data = data.frame(
		x = rep(1:length(leader.index), 2),
		y = c(leader.index, sp500.index),
		g = c(rep(1, length(leader.index)), rep(2, length(leader.index)))
		)
		ggplot(data) + geom_line(aes(x, y, group=factor(g), color=factor(g)))
}
	
### Compute the s & p 500 index.
# ts.plot(cal_sp500_index('../data/sp500_1374586200_1374609600.raw', '../resource/sp500_market_cap.table'))
cal_sp500_index <- function(rawfile, capfile) {
	data = read.table(rawfile, header=T)
	rbase = read.table(capfile, header=F, , col.names=c('stock', 'cap'))
	rownames(rbase) = rbase[,1]
	
	ndata = apply(sapply(colnames(data), function(x) { data[, x] * rbase[x, 2] / sum(rbase[,2]) } ), 1, sum)
}

cal_leader_index <- function(topk = 0) {
	
	config = read.table('../resource/config.file', header=F, sep=',')
	rownames(config) = config[,1]
	# sp500_128_1374592920_1374600540.data
	config[,2] = as.vector(config[,2])
	
	from = as.numeric(config['start_stamp', 2])
	to = as.numeric(config['end_stamp', 2]) - as.numeric(config['step_seconds', 2]) * (as.numeric(config['window_size', 2]) - 1)
	by = as.numeric(config['step_seconds', 2]) * as.numeric(config['step_day', 2])
	#print(to)
	data.list = c()
	rank.list = c()
	num = 1
	for(i in seq(from=from, to=to, by=by)) {
		j = i + as.numeric(config['step_seconds', 2]) * (as.numeric(config['window_size', 2]) - 1)
		
		## [i, j], sp500_128_1374586200_1374593820.data, sp500_128_1374601980_1374609600_comps_thresh_0
	 	data.list[num] = paste('../data/', config['file_prefix', 2], i, '_', j, '.data', sep='')
	 	rank.list[num] = paste('../data/', config['file_prefix', 2], i, '_', j, '_comps_thresh_0.crank', sep='')
	 	num = num + 1
	}
	#print(data.list)
	
	leader.index = matrix(0, nrow=as.numeric(config['window_size', 2]), ncol=length(data.list))
	for(i in 1:length(data.list)) {
		rr = read.table(rank.list[10], header=F, col.names=c('stock', 'value', 'cap', 'sector', 'industry'))
		data = read.table(data.list[i], header=T)
		
		rr = subset(rr, stock %in% intersect(rr[,1], colnames(data)))
		if(topk > 0) rr = rr[1:topk, ]
		
		leader.index[, i] = apply(apply(rr, 1, function(x) {
			data[, x[1]] * as.numeric(x[2])/sum(as.numeric(rr[, 2]))
		}), 1, sum)
	}
	
	### reconstruct from leader.index matrix.
	res.leader.index = c()
	from = 1
	for(i in 1:ncol(leader.index)) {
		res.leader.index[from:(from + length(leader.index[, i]) - 1)] = leader.index[, i]
		
		from = from + as.numeric(config['step_day', 2])
		#print(length(res.leader.index))
	}
	res.leader.index
	#print(length(res.leader.index))
}
