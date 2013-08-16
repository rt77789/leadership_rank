
library(ggplot2)
library(pracma)
library(TTR)

source('util.R')

plot_leadership_index <- function() {
		
		leader.index = cal_leader_index(1)
		sp500.index = cal_sp500_index()
		
		leader.index = (leader.index - mean(leader.index)) / sd(leader.index)
		sp500.index = (sp500.index - mean(sp500.index)) / sd(sp500.index)
		
		sma.window = 5
		leader.index.sma = SMA(leader.index, sma.window)
		leader.index.sma[1:(sma.window-1)] = leader.index[1:(sma.window-1)]
		#print(leader.index.sma)
		
		data = frame_convert(data.frame(sp500 = norm_vector(sp500.index), leader = norm_vector(leader.index), leader.sma = leader.index.sma))
				
		dev.new()
		p = ggplot(data) + geom_line(aes(x, y, group=factor(g), color=factor(g)))
		for(suf in c('.eps', '.pdf')) {
			ggsave(p, file=paste(config['pics_dir', 2], 'leadership_index_', config['start_stamp', 2], '_', config['end_stamp', 2], suf, sep=''), width=1.6, height=0.6, scale=5)
		}
		p
}
