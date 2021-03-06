
suppressMessages(library(vars))
suppressMessages(library(fUnitRoots))
# 
### Load config.file.
config = read.table('../resource/config.file', header=F, sep=',')
rownames(config) = config[,1]
config[,2] = as.vector(config[,2])


### Compute the s & p 500 index.
# ts.plot(cal_sp500_index('../data/sp500_1374586200_1374609600.raw', '../resource/sp500_market_cap.table'))
cal_sp500_index <- function() {
	
	data = read.table(get_filename_by_suffix('raw'), header=T)
	rbase = read.table('../resource/sp500_market_cap.table', header=F, col.names=c('stock', 'cap'))
	rownames(rbase) = rbase[,1]
	
	ndata = apply(sapply(colnames(data), function(x) { data[, x] * rbase[x, 2] / sum(rbase[,2]) } ), 1, sum)
}

cal_sp500_sector_index <- function(sec, weight.type) {
	data = read.table(get_filename_by_suffix('raw'), header=T)
	rbase = read.table('../resource/sp500_market_cap.table', header=F, col.names=c('stock', 'cap'))
	rrank = read.table(get_filename_by_suffix('mcrank'), header=F, col.names=c('stock', 'score', 'cap', 'sector', 'industry'))
	
	rownames(rrank) = rrank[,1]
	rownames(rbase) = rbase[,1]
	
	sector.list = read.table('../resource/sp500.sector', header=F, col.names=c('stock', 'sector'), sep=',')
	csec = intersect(colnames(data), subset(sector.list, sector == sec)$stock)
	data = data[, csec]
	
	ndata = switch(weight.type,
             'cap' = apply(sapply(colnames(data), function(x) { data[, x] * rbase[x, 2] / sum(rbase[,2]) } ), 1, sum),
             'score' = apply(sapply(colnames(data), function(x) { data[, x] * rrank[x, 2] / sum(rrank[,2]) } ), 1, sum))
}

#### Compute leadership index, topk is the used number of leaders.
cal_leader_index <- function(topk = 0) {
	
	from = as.numeric(config['start_date', 2])
	to = as.numeric(config['end_date', 2]) - as.numeric(config['step_seconds', 2]) * (as.numeric(config['window_size', 2]) - 1)
	by = as.numeric(config['step_seconds', 2]) * as.numeric(config['step_day', 2])
	#print(to)
	data.list = c()
	rank.list = c()
	num = 1
	for(i in seq(from=from, to=to, by=by)) {
		j = i + as.numeric(config['step_seconds', 2]) * (as.numeric(config['window_size', 2]) - 1)
		
		## [i, j], sp500_128_1374586200_1374593820.data, sp500_128_1374601980_1374609600_comps_thresh_0
	 	data.list[num] = paste(config['data_dir', 2], config['file_prefix', 2], i, '_', j, '.data', sep='')
	 	rank.list[num] = paste(config['data_dir', 2], config['file_prefix', 2], i, '_', j, '_comps_thresh_0.crank', sep='')
	 	num = num + 1
	}
	#mean.rank.list = paste(config['data_dir', 2], config['file_prefix', 2], from, '_', as.numeric(config['end_stamp', 2]), '.mcrank', sep='')
	#mean.rank.list = '../data/sp100_128_1374586200_1374609600_step_1/sp100_128_1374601980_1374609600_comps_thresh_0.crank'
	#rank.list = c('../data/sp100_128_1374586200_1374609600_step_1/sp100_128_1374586200_1374609600.mcrank', rank.list)
	
	leader.index = matrix(0, nrow=as.numeric(config['window_size', 2]), ncol=length(data.list))
	for(i in 1:length(data.list)) {
		rr = read.table(rank.list[ floor((i-1) / 64) + 1], header=F, col.names=c('stock', 'value', 'cap', 'sector', 'industry'))
		data = read.table(data.list[i], header=T)
		
		rr = subset(rr, stock %in% intersect(rr[,1], colnames(data)))
		if(topk > 0) rr = rr[1:topk, ]
		
		leader.index[, i] = apply(apply(rr, 1, function(x) {
			data[, x[1]] * as.numeric(x[2])/sum(as.numeric(rr[, 2]))
		}), 1, sum)
	}
	
	### reconstruct from leader.index matrix.
	res.leader.index = c()
	len = nrow(leader.index)
	from = 1
	for(i in 1:ncol(leader.index)) {
		#if(i > 1) leader.index[, i] = leader.index[, i] / leader.index[1, i] * leader.index[nrow(leader.index), i-1]
		#if(i > 1) {
		#	res.leader.index[from + len - 1] = leader.index[len, i]
		#}
		#else {
		#	res.leader.index[from:(from + len - 1)] =(leader.index[, i])
		#}
		
		res.leader.index[from:(from + len - 1)] = norm_vector(leader.index[, i])
		from = from + as.numeric(config['step_day', 2])
		#print(length(res.leader.index))
	}
	res.leader.index
	#print(length(res.leader.index))
}

### Construct the file name by suffix.
get_filename_by_suffix <- function(suf) {
	from = as.numeric(config["start_date", 2])
	to = as.numeric(config["end_date", 2])
	mifile = paste(config['data_dir', 2], config["file_prefix", 2], from, "_", to, ".", suf, sep = "")
}

### convert a data.frame (each column is a group data) to the format of ggplot2.
frame_convert <- function(f) {
	res = matrix(nrow = 0, ncol = 3)

	for (i in 1:ncol(f)) {
		tb = matrix(nrow = nrow(f), ncol = 3)
		tb[, 1] = rep(colnames(f)[i], nrow(f))
		tb[, 2] = 1:nrow(f)
		tb[, 3] = f[, i]
		
		res = rbind(res, tb)
	}

	res = data.frame(x = as.numeric(res[, 2]), y = as.numeric(res[, 3]), g = res[,1])
	#names(res) = c('Stock', 'x', 'y', 'date')
}

### Normalize 
norm_vector <- function(v) {
	(v - mean(v)) / sd(v)
}

### Check whether a time series is stationary.
check_stationary <- function(ts) {

	### p-value is less than 0.05 means the data is stationary and doesn't need to be differenced.
	#print(adfTest(ts))
	ifelse(attr(adfTest(ts), 'test')$p.value < 0.05, T, F) 
}

### 
differ_time_series <- function(ts) {
	(ts[-1] - ts[-length(ts)])/ts[-length(ts)]
}

### Test the granger causality between ts1 and ts2.
granger_test <- function(ts1, ts2) {
	res = 0
	### Selected lag under SC critieria.
	td = data.frame(x = ts1, y = ts2)
	slag = VARselect(td, lag.max = 14, type = "const")$selection
	print(slag)
	var.m = VAR(td, p = slag[3], type = "const")

	rc = causality(var.m, cause = "x")

	print(rc)
	if (rc$Granger$p.value < 0.05) {
		res = 1
	}

	rc = causality(var.m, cause = "y")
	print(rc)
	if (rc$Granger$p.value < 0.05) {
		res = -1
	}
	res
}


