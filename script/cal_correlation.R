
set.seed(seed=1)

#### Build the graph of stock relationships.
build_graph <- function(threshold = 0.4) {
  d = read.table('../data/sp_128.data', header=T)
  
  col = ncol(d)
  row = nrow(d)
  
  mat = matrix(0, nrow = col, ncol = col)
  
  rownames(mat) = colnames(d)[1:col]
  colnames(mat) = colnames(d)[1:col]
  lags = mat
  
  ### Threshold, which is used to filter the too small cross-correlation coefficient.
 # threshold = 0.4
  
  ptm = proc.time()
  
  for(i in 1:col) {
    print(i)
    for(j in 1:col) {
      
      if(var(d[,i]) == 0 || var(d[,j]) == 0) {
        mat[i,j] = 0
      }
      else {    
        res = ccf(d[,i], d[,j], type='correlation', lag.max=row/2, plot=F)
        
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
  print(proc.time() - ptm)
  
  mat
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
  ro = order(rank, decreasing=T)
  matrix(c(rownames(rank)[ro], rank[ro]), ncol=2, byrow=F)
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
  sink('../data/cal_correlation.log')
  
  mat = build_graph(0)
  write.table(mat, file='../data/all_comps_thresh_0.data', row.names=T, col.names=T)
  
  rank = page_rank(mat)
  rr = disp_stock_rank(rank)
  write.table(rr, file='../data/all_comps_thresh_0.rank', row.names=F, col.names=F, quote=F)
  
  sink()
}

####
