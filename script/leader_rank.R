
set.seed(seed=1)

#### Build the graph of stock relationships.
build_graph <- function(fd, threshold = 0.4) {
	#dd = read.table('../data/sp500_200.data', header=T)
	dd = read.table(fd, header=T)
	piece = 0;
	lag.max = 14

	row = nrow(dd)
	block = row

	mat2 = matrix(0, nrow = ncol(dd), ncol = ncol(dd))

	ptm = proc.time()

	for(step in seq(from=1, to=row, by=block/2)) {
		if(step + block-1 > row) {break}
		piece = piece + 1
		d = dd[seq(step,step+block-1),]
		# Compute the relative change.
		#d = apply(d, 2, function(x) { (x[-1] - x[-length(x)]) / x[-length(x)] })

		col = ncol(d)


		mat = matrix(0, nrow = col, ncol = col)

		rownames(mat) = colnames(d)[1:col]
		colnames(mat) = colnames(d)[1:col]
		lags = mat

		### Threshold, which is used to filter the too small cross-correlation coefficient.
		# threshold = 0.4



		for(i in 1:col) {
			print(i)
			for(j in 1:col) {
				if(var(d[,i]) == 0 || var(d[,j]) == 0) {
					mat[i,j] = 0
				}
				else {    
					res = ccf(d[,i], d[,j], type='correlation', lag.max=lag.max, plot=F)

					pos = which(res$acf == max(res$acf))[1]

					if(res$lag[pos] > 0 && res$acf[pos] > threshold) {
						### x lead y.
						### Make sure the correlation is positive and bigger than the threshold.
						mat[i,j] = res$acf[pos]
						lags[i,j] = pos - row/2 - 1
					}
					else {
						mat[i,j] = 0
					}
				}
			}
		}
		mat2 = mat2 + mat
	}
	print(proc.time() - ptm)
	mat2 = mat2 / piece;
	mat2
}

### 
page_rank <- function(mat, max_error = 1e-6, lambda = 0.85) {
	n = nrow(mat)
	### Normalize each row, if sum of each row is zero, then leave them as all zeros.
	#mat = t(apply(mat, 1, function(x) { if(sum(x) > 0) { x / sum(x) } else {x}}))  
	#mat = t(apply(mat, 1, function(x) { if(sum(x) > 0) { (x > -1) * 1./ n } else {x}}))

	mat = lambda * mat + matrix((1 - lambda) / n, n, n)

	rank = matrix(runif(n * 1), n, 1)
	prank = matrix(Inf, n, 1)

	while( sum((rank - prank)**2) > max_error ) {
		prank = rank;

		rank = mat %*% rank
		rank = apply(rank, 2, function(x) { if(sum(x) > 0) { x / sum(x) } else {x}})
	}
	rank
}

disp_stock_rank <- function(rank) {
	cap = read.table('../data/sp500_market_cap.table', header=F)	
	rownames(cap) = paste(cap[,1], '.raw', sep='')	

	sec = read.table('../data/sp_500.sector', sep=',')
	rownames(sec) = paste(sec[,1], '.raw', sep='')

	ro = order(rank, decreasing=T)
	rn = rownames(rank)
	matrix(c(rn[ro], rank[ro], as.vector(cap[rn[ro], 2]), as.vector(sec[rn[ro], 2])), ncol=4, byrow=F)
}

### Read compressed data, but it's still non-efficienct.
read_compress_data <-function(fd, fm) {
	cd = read.table('../data/all_comps_thresh_0.compress', header=F)
	cname = colnames(read.table('../data/company.list', header=T))

	mat = matrix(0, length(cname), length(cname))
	mat = apply(cd, 1, function(x) { mat[x[1], x[2]] = x[3]}) 
}

#####
run <- function() {
	epf = '../data/sp500_128'
	sink(paste(epf, '.log', sep=''))

	mat = build_graph(paste(epf, '.data', sep=''), 0)
	write.table(mat, file=paste(epf, '_comps_thresh_0.data', sep=''), row.names=T, col.names=T)

	rank = page_rank(mat)
	rr = disp_stock_rank(rank)
	write.table(rr, file=paste(epf, '_comps_thresh_0.rank', sep=''), row.names=F, col.names=F, quote=F)

	# Compute the sum influence of each sector.
	print(sapply(levels(as.factor(rr[,4])), function(x) { sum(as.numeric(rr[which(x == rr[,4]), 2])) }))
	# Compute the mean influence of each sector.
	print(sort(sapply(levels(as.factor(rr[,4])), function(x) { mean(as.numeric(rr[which(x == rr[,4]), 2])) }), decreasing=T))

	sink()
}

####
