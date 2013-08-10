
library(vars)


d = read.table("../data/sp500_128.data", header = T)

d = apply(d, 2, function(x) {
	(x[-1] - x[-length(x)])/x[-length(x)]
})

sname = colnames(d)

mat = matrix(0, length(sname), length(sname))

rownames(mat) = sname
colnames(mat) = sname

sink('../data/tmp')

for (i in 1:ncol(d)) {
	print(i)
	for (j in i:ncol(d)) {
		if (i == j) {
			next
		}
		### Selected lag under SC critieria.
		slag = VARselect(d[, c(sname[i], sname[j])], lag.max = 14, type='const')$selection
		print(slag)
		var.m = VAR(d[, c(sname[i], sname[j])], p = slag[3], type = "const")

		rc = causality(var.m, cause = sname[i])

		if (rc$Granger$p.value < 0.05) {
			mat[i, j] = 1
		}
		
		rc = causality(var.m, cause = sname[j])
		if (rc$Granger$p.value < 0.05) {
			mat[j, i] = 1

		}
	}
}

sink()