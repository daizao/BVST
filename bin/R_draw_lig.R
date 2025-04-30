if (!require('ggplot2')) install.packages('ggplot2')
if (!require('tidyverse')) install.packages('tidyverse')


library(ggplot2)
library(tidyverse)

args=commandArgs(T)

df <- data.table::fread(args[1],sep = "\t") %>%
  select(c("Molname","Target","Energy")) %>%
  filter(Energy < 0) %>%
  top_n(100,Energy) %>%
  arrange()

p <- ggplot(df,mapping = aes(x= fct_reorder(Molname,Energy),y=Energy,fill=Target)) +
  geom_bar(stat = "identity",width = 0.3) +
  theme_bw() +
  coord_flip() +
#  theme(panel.grid=element_blank()) +
  xlab("Molecular Name")

pdf(file = args[2])
p
dev.off()
