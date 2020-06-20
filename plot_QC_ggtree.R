
list.files()

library(ggtree)
library(treeio)
library(ggplot2)
library(ape)

qc <- read.tree("RESULT.labeled.tre.qc")
qd <- read.tree("RESULT.labeled.tre.qd")
qi <- read.tree("RESULT.labeled.tre.qi")


# process node labels of above three labeled trees
# qc tree
tree <- qc
tree$node.label <- gsub("qc=","",tree$node.label)
View(tree$node.label)
write.tree(tree,"tree_qc.tre")
# qd tree
tree <- qd
tree$node.label <- gsub("qd=","",tree$node.label)
View(tree$node.label)
write.tree(tree,"tree_qd.tre")
# qi tree
tree <- qi
tree$node.label <- gsub("qi=","",tree$node.label)
View(tree$node.label)
write.tree(tree,"tree_qi.tre")


# read 3 modified tree files for QC/QD/QI
tree_qc <- read.newick("tree_qc.tre", node.label='support')
tree_qd <- read.newick("tree_qd.tre", node.label='support')
tree_qi <- read.newick("tree_qi.tre", node.label='support')


# add a customized label for internode or inter-branch, i.e., qc/qd/qI
score_raw = paste(tree_qc@data$support,"/",tree_qd@data$support,"/",tree_qi@data$support,sep="")
score = gsub("NA/NA/NA","",score_raw)
score = gsub("NA","-",score)
View(score)


# set labeled QC tree as the main plot tree
tree <- tree_qc
tree@data$score <- score


#####################################################
# Partitioning quartet concordance. QC values were divided into four categories and this
# information was used to color circle points. 

# drop the internodes without QC vaule
root <- tree@data$node[is.na(tree@data$support)]

pdf(file="00.treeQC_rect_circ.pdf", width = 16, height = 18)

# (1)color circle points
ggtree(tree, size=0.5) +
  geom_tiplab(size=2) + xlim(0, 0.12) +
  geom_nodepoint(aes(subset=!isTip & node != root, fill=cut(support, c(1, 0.2, 0, -0.05, -1))),
                 shape=21, size=4) +
  theme_tree(legend.position=c(0.9, 0.18)) +
  scale_fill_manual(values=c("#2F4F4F", "#98F898", "#FFCC99","#FF6600"),
                    guide="legend", name="Quartet Concordance(QC)",
                    breaks=c("(0.2,1]","(0,0.2]","(-0.05,0]","(-1,-0.05]"),
                    labels=expression(QC>0.2, 0 < QC * " <= 0.2", -0.05 < QC * " <= 0", QC <= -0.05))

# (2)color branch
ggtree(tree, aes(color=cut(support, c(1, 0.2, 0, -0.05, -1))), layout="circular", size=1) +
  theme_tree(legend.position=c(0.85, 0.24)) +
  scale_colour_manual(values=c("#2F4F4F", "#98F898", "#FFCC99","#FF6600"),
                      breaks=c("(0.2,1]","(0,0.2]","(-0.05,0]","(-1,-0.05]"),
                      na.translate=T, na.value="gray",
                      guide="legend", name="Quartet Concordance(QC)",
                      labels=expression(QC>0.2, 0 < QC * " <= 0.2", -0.05 < QC * " <= 0", QC <= -0.05))

# (3)color circle points and label each internode with QC/QD/QI
ggtree(tree, size=0.5) +
  geom_tiplab(size=2) + xlim(0, 0.12) +
  geom_nodepoint(aes(subset=!isTip & node != root, fill=cut(support, c(1, 0.2, 0, -0.05, -1))),
                 shape=21, size=4) +
  theme_tree(legend.position=c(0.9, 0.18)) +
  scale_fill_manual(values=c("#2F4F4F", "#98F898", "#FFCC99","#FF6600"),
                    guide="legend", name="Quartet Concordance(QC)",
                    breaks=c("(0.2,1]","(0,0.2]","(-0.05,0]","(-1,-0.05]"),
                    labels=expression(QC>0.2, 0 < QC * " <= 0.2", -0.05 < QC * " <= 0", QC <= -0.05))+
  geom_text(aes(label=score, x=branch), size=2, vjust=-.5)

dev.off()





