
set.seed(seed = 1)

source('util.R')

#### Build the graph of stock relationships.
build_graph <- function(fd, threshold = 0.4, type = "ccf", lag.max = 14) {
	#dd = read.table('../data/sp500_200.data', header=T)
	dd = read.table(fd, header = T)
	piece = 0

	row = nrow(dd)
	block = row
	#lag.max = 14
	mat2 = matrix(0, nrow = ncol(dd), ncol = ncol(dd))

	ptm = proc.time()

	for (step in seq(from = 1, to = row, by = block/2)) {
		if (step + block - 1 > row) {
			break
		}
		piece = piece + 1
		d = dd[seq(step, step + block - 1), ]
		# Compute the relative change.
		#d = apply(d, 2, function(x) { (x[-1] - x[-length(x)]) / x[-length(x)] })

		col = ncol(d)
		sname = colnames(d)

		mat = matrix(0, nrow = col, ncol = col)

		rownames(mat) = colnames(d)[1:col]
		colnames(mat) = colnames(d)[1:col]
		lags = mat

		### Threshold, which is used to filter the too small cross-correlation coefficient.
		# threshold = 0.4
		for (i in 1:col) {
			print(i)
			for (j in 1:col) {
				if (var(d[, i]) == 0 || var(d[, j]) == 0 || i == j) 
					next
				mat[i, j] = 0

				res = ccf(d[, i], d[, j], type = "correlation", lag.max = lag.max, plot = F)

				pos = which(res$acf == max(res$acf))[1]

				if (type == "ccf") {
					if (res$lag[pos] < 0 && res$acf[pos] > threshold) {
						### i lead j, and pagerank works at this style.
						### Make sure the correlation is positive and bigger than the threshold.
						mat[i, j] = res$acf[pos]
						lags[i, j] = pos - row/2 - 1
					}
				} else if (type == "eccf") {
					res$acf[res$acf < 0] = 0
					necc = mean(res$acf[res$lag < 0])
					pecc = mean(res$acf[res$lag > 0])
					ecc = max(necc, pecc)

					#if(res$lag[pos] < 0 && res$acf[pos] > threshold) 
					if (necc > pecc && ecc > threshold) {
						### i lead j, and pagerank works at this style.
						### Make sure the correlation is positive and bigger than the threshold.
						mat[i, j] = ecc
						lags[i, j] = pos - row/2 - 1
					}
				} else if (type == "granger") {
					### Check stationary!!!
					x = differ_time_series(d[, sname[i]])
					y = differ_time_series(d[, sname[j]])
					
					if(!check_stationary(x)) stop(sname[i])
					if(!check_stationary(y)) stop(sname[j])
					
					td = data.frame(x = x, y = y)
					
					### Selected lag under SC critieria.
					slag = VARselect(td, lag.max = lag.max, type='const')$selection
					#print(slag)
					var.m = VAR(td, p = slag[3], type = "const")
					rc = causality(var.m, cause = 'x')

					if (rc$Granger$p.value < 0.05) mat[i, j] = 1
				} else {}
			}
		}
		mat2 = mat2 + mat
	}
	print(proc.time() - ptm)
	mat2 = mat2/piece
	mat2
}

### 
page_rank <- function(mat, max_error = 1e-6, lambda = 0.85) {
	mat = as.matrix(mat)
	n = nrow(mat)
	### Normalize each column, if sum of each row is zero, then leave them as all zeros.
	#mat = t(apply(mat, 2, function(x) { if(sum(x) > 0) { x / sum(x) } else {x}}))  
#mat = t(apply(mat, 2, function(x) { if(sum(x) > 0) { (x > -1) * 1./ n } else {x}}))

	rank = matrix(runif(n * 1), n, 1)
	prank = matrix(Inf, n, 1)

	while (sum((rank - prank)^2) > max_error) {
		prank = rank

		rank = lambda * mat %*% rank + matrix((1 - lambda)/n, n, 1)
		# rank = apply(rank, 2, function(x) {
			# if (sum(x**2) > 0) {
				# x/sum(x**2)
			# } else {
				# x
			# }
		# })
		
		rank = rank / sum(rank ** 2)
	}
	rank / sum(rank)
}

### 
page_rank2 <- function(mat, max_error = 1e-06, lambda = 0.85) {
	mat = as.matrix(mat)
	n = nrow(mat)
	### Normalize each column, if sum of each row is zero, then leave them as all zeros.
	#mat = t(apply(mat, 2, function(x) { if(sum(x) > 0) { x / sum(x) } else {x}}))  
#mat = t(apply(mat, 2, function(x) { if(sum(x) > 0) { (x > -1) * 1./ n } else {x}}))

	rank = matrix(runif(n * 1), n, 1)
	prank = matrix(Inf, n, 1)

	rank = solve(diag(nrow(mat)) - lambda * mat) %*% matrix((1 - lambda)/n, n, 1)
	
	rank = rank - min(rank)
	rank = rank / sum(rank)
	rank
}


## Circuit Model.
cal_single_potential <- function(node, mat, seeds, iternum = 50, lambda = 0.85) {
	#print(node)
	n = nrow(mat)
	poten = matrix(0, n, 1)
	envec = matrix(0, n, 1)
	snvec = matrix(0, n, 1)
	snvec[seeds] = 1
	envec[node] = 1

	for (i in 1:iternum) {
		poten = lambda * (mat %*% poten + envec) 
		#### 
		poten[poten & snvec] = 0
	}

	poten = poten/poten[node]
}

cal_single_potential2 <- function(node, mat, seeds, iternum = 50, lambda = 0.85, cap = 1) {
	#print(node)
	n = nrow(mat)
	poten = matrix(0, n, 1)
	envec = matrix(0, n, 1)
	snvec = matrix(0, n, 1)
	snvec[seeds] = 1
	envec[node] = cap
	poten[node] = cap

	for (i in 1:iternum) {
		poten = lambda * (mat %*% poten + envec) 
		#### 
		poten[poten & snvec] = 0
	}

	poten = poten/poten[node]
}

cal_seed_potential <- function(mat, topk) {
	# Make sure each column of mat is normalized, which means sum of each column is 1.
	mat = t(apply(mat, 2, function(x) {
		if (sum(x) > 0) {
			x/sum(x)
		} else {
			x
		}
	}))

	n = nrow(mat)
	seeds = c()
	res = matrix(0, topk, 1)
	
	for (i in 1:topk) {
		rank = sapply(1:n, function(x) {
			sum(cal_single_potential(x, mat, seeds))
		})
		rank = matrix(rank, n, 1)
		rownames(rank) = colnames(mat)
		
		ro = order(rank, decreasing = T)
		# rownames(rank)[ro[1]]
		seeds[i] = ro[1]
		res[i] = rank[ro[1]]
	}
#	colnames(mat)[seeds]
	rownames(res) = colnames(mat)[seeds]
	res
}

## Compute potentials
cal_potential <- function(mat) {

	# Make sure each column of mat is normalized, which means sum of each column is 1.
	mat = t(apply(mat, 2, function(x) {
		if (sum(x) > 0) {
			x/sum(x)
		} else {
			x
		}
	}))

	n = nrow(mat)
	seeds = c()
	
	cap = read.table("../resource/sp500_market_cap.table", header = F)
	rownames(cap) = cap[, 1]
	
	rank = sapply(1:n, function(x) {
		#print(cap[rownames(mat)[x], 2] / max(cap[,2]))
		#sum(cal_single_potential(x, mat, seeds))
		sum(cal_single_potential2(x, mat, seeds, cap = cap[rownames(mat)[x], 2] / max(cap[,2])))
	})
	rank = matrix(rank, n, 1)
	rownames(rank) = colnames(mat)
	rank
}

disp_stock_rank <- function(rank) {
	cap = read.table("../resource/sp500_market_cap.table", header = F)
	rownames(cap) = cap[, 1]

	sec = read.table("../resource/sp500.sector", sep = ",")
	rownames(sec) = sec[, 1]
	
	ind = read.table("../resource/sp500.industry", sep = ",")
	rownames(ind) = ind[, 1]
	

	ro = order(rank, decreasing = T)
	rn = rownames(rank)
	data.frame(stock = rn[ro], score = rank[ro], cap = as.vector(cap[rn[ro], 2]), sector = as.vector(sec[rn[ro], 
		2]), industry = as.vector(ind[rn[ro], 2]))
}

### Read compressed data, but it's still non-efficienct.
read_compress_data <- function(fd, fm) {
	cd = read.table("../data/all_comps_thresh_0.compress", header = F)
	cname = colnames(read.table("../resource/company.list", header = T))

	mat = matrix(0, length(cname), length(cname))
	mat = apply(cd, 1, function(x) {
		mat[x[1], x[2]] = x[3]
	})
}

#####
run <- function(epf) {
	#epf = '../data/sp_128'
	sink(paste(epf, ".log", sep = ""))

	mat = build_graph(paste(epf, ".data", sep = ""), 0, 'ccf')
	write.table(mat, file = paste(epf, "_comps_thresh_0.mat", sep = ""), row.names = T, col.names = T)

	#### Pagerank Model #####
	rank = page_rank(mat)
	rr = disp_stock_rank(rank)

	write.table(rr, file = paste(epf, "_comps_thresh_0.rank", sep = ""), row.names = F, col.names = F, quote = T)

	# Compute the sum influence of each sector.
	print("Sum influence of each sector in Pagerank Model.")
	print(sort(sapply(levels(as.factor(rr[, 4])), function(x) {
		sum(as.numeric(rr[which(x == rr[, 4]), 2]))
	}), decreasing = T))
	print("Mean influence of each sector in Pagerank Model.")
	# Compute the mean influence of each sector.
	print(sort(sapply(levels(as.factor(rr[, 4])), function(x) {
		mean(as.numeric(rr[which(x == rr[, 4]), 2]))
	}), decreasing = T))

	###### Circuit model. ######
	rank = cal_potential(mat)
	rr = disp_stock_rank(rank)

	write.table(rr, file = paste(epf, "_comps_thresh_0.crank", sep = ""), row.names = F, col.names = F, quote = T)

	# Compute the sum influence of each sector.
	print("Sum influence of each sector in Circuit Model.")
	print(sort(sapply(levels(as.factor(rr[, 4])), function(x) {
		sum(as.numeric(rr[which(x == rr[, 4]), 2]))
	}), decreasing = T))
	print("Mean influence of each sector in Circuit Model.")
	# Compute the mean influence of each sector.
	print(sort(sapply(levels(as.factor(rr[, 4])), function(x) {
		mean(as.numeric(rr[which(x == rr[, 4]), 2]))
	}), decreasing = T))

	sink()
}

####
args <- commandArgs(TRUE)
#epf = '../data/sp_128'
#print(args)
print(args)
run(args[1])
