
library("fUnitRoots")

check_stationary <- function(fn) {

	### p-value is less than 0.05 means the data is stationary and doesn't need to be differenced.
	#x = rnorm(1000)
#adfTest(x)

	#ts.plot(x)
	
	d = read.table("../data/sp500_128.data", header = T)

	d = apply(d, 2, function(x) {
		(x[-1] - x[-length(x)])/x[-length(x)]
	})

	res = apply(d, 2, function(x) {
		a = adfTest(x)
		attr(a, "test")$p.value
	})
	if(sum(res > 0.05)) {
		print(fn)
		print(res[res > 0.05])
	}

}
#### Test all data w.r.t different timestamps. ####

args <- commandArgs(TRUE)
#epf = '../data/sp_128'
#print(args)

check_stationary(args[1])