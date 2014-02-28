
args <- commandArgs(TRUE)

config = read.table('~/code/project/leadership_rank/resource/config.file', header=F, sep=',');

d = read.table(args[1], header=F, sep=',');
id = read.table(paste('~/code/project/leadership_rank/resource/', config[config[,1] == 'prefix', 2],'.datelist', sep=''), header=F);
res = data.frame(id=1:nrow(id), date=id);

for(i in 3:ncol(d)) {
	res[,i] = approx(x = d[,1], y = d[, i], xout=1:nrow(id))$y;
	
	for(j in 1:nrow(res)) {
		if(!is.na(res[j, i])) {
			for(k in 1:j) {
				if(is.na(res[k, i])) {
					res[k, i] = res[j, i];
				}
			}
			break;
		}
	}
	
	for(j in nrow(res):1) {
		if(!is.na(res[j, i])) {
			for(k in j:nrow(res)) {
				if(is.na(res[k, i])) {
					res[k, i] = res[j, i];
				}
			}
			break;
		}
	}
}
#print(res)

write.table(res, file=args[2], quote=F, sep=',', row.names=F, col.names=F)

