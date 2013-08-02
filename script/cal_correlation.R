
d = read.table('../data/sp_128.data', header=T)

col = 100 # ncol(d)
row = nrow(d)

mat = matrix(0, nrow = col, ncol = col)


rownames(mat) = colnames(d)[1:col]
colnames(mat) = colnames(d)[1:col]
lags = mat

### Threshold, which is used to filter the too small cross-correlation coefficient.
threshold = 0.4

ptm = proc.time()

for(i in 1:col) {
  for(j in 1:col) {
    
    if(var(d[,i]) == 0 || var(d[,j]) == 0) {
      mat[i,j] = 0
    }
    else {    
      res = ccf(d[,i], d[,j], type='correlation', lag.max=row/2, plot=F)
      
      pos = which(res$acf == max(res$acf))
      
      if(res$lag[pos] < 0 && res$acf[pos] > threshold) {
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
proc.time() - ptm

### 