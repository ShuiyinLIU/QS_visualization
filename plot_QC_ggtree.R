#!/usr/bin/env Rscript
# created by Shuiyin Liu at 15:43, FRI, 2023-11-17


# import packages
library(ggtree)
library(treeio)
library(ggplot2)
library(ape)
library(optparse)


#commandArgs(TRUE)


# set parameters
# default != NULL
option_list <- list(
  make_option(opt_str = c("-c", "--qctreefile"), type = "character", default = NULL,
              help = "Required, tree file with QC value labeled, that is one of outputs of QS method: default = NULL"),
  
  make_option(opt_str = c("-d", "--qdtreefile"), type = "character", default = NULL,
              help = "Required, tree file with QD value labeled, that is one of outputs of QS method: default = NULL"),
  
  make_option(opt_str = c("-i", "--qitreefile"), type = "character", default = NULL,
              help = "Required, tree file with QI value labeled, that is one of outputs of QS method: default = NULL"),
  
  make_option(opt_str = c("-o", "--outpath"), type = "character", default = "./",
              help = "Required, output directory: default = \"./\""),
  
  make_option(opt_str = "--pdfwidth", type = "numeric", default = 8,
              help = "Optional, the width of the graphics region in inches: default = 8"),
  
  make_option(opt_str = "--pdfheight", type = "numeric", default = 11,
              help = "Optional, the height of the graphics region in inches: default = 11"),
  
  make_option(opt_str = "--branchlength", type = "character", default = "branch.length",
              help = "Optional, variable for scaling branch, if \"none\" draw cladogram 
              (that is useful when your tree has a few abnormal long branch length). 
              default = \"branch.length\""),

  make_option(opt_str = "--branchsize", type = "character", default = 1,
              help = "Optional, the size of tree branch: default = 1"),
  
  make_option(opt_str = "--tiplabsize", type = "numeric", default = 2,
              help = "Optional, the size of tip labels: default = 2"),
  
  make_option(opt_str = "--nodepointsize", type = "numeric", default = 4,
              help = "Optional, the size of node points: default = 4"),
  
  make_option(opt_str = "--qstextsize", type = "numeric", default = 2,
              help = "Optional, the size of branch labels of three QS values (QC/QD/QI): default = 2"),
  
  make_option(opt_str = "--qstextvjust", type = "numeric", default = -0.5,
              help = "Optional, vertical adjust for branch labels of three QS values (QC/QD/QI): default = -0.5"),
  
  make_option(opt_str = "--xlimmin", type = "numeric", default = NULL,
              help = "Optional, set the min value (usually set as 0) for x axis limits specially for
              Tree panel when tip labels outside pannel. Must setted together with \"--xlimmax\". 
              More bigger xlimmin value, more narrower (zoom out) tree plotted along x-axis, and 
              vice versa (zoom in). You can use theme_tree2() for default x-axis limits. default = NULL"),
  
  make_option(opt_str = "--xlimmax", type = "numeric", default = NULL,
              help = "Optional, set the max value for x axis limits specially for
              Tree panel when tip labels outside pannel. Must setted together with \"--xlimmin\". 
              More bigger xlimmax value, more narrower (zoom out) tree along x-axis, and vice versa (zoom in).
              You can use theme_tree2() for default x-axis limits. default = NULL")
)





# parse parameters
args_parser <- OptionParser(option_list = option_list, 
                            usage = "Usage: Rscript %prog\n
                            For example1, Rscript %prog -h\n
                            For example2, Rscript %prog -c example/RESULT.labeled.tre.qc -d example/RESULT.labeled.tre.qd -i example/RESULT.labeled.tre.qi\n
                            For example2, Rscript %prog -c example/RESULT.labeled.tre.qc -d example/RESULT.labeled.tre.qd -i example/RESULT.labeled.tre.qi
                            --branchlength none\n
                            For example4, Rscript %prog -c example/RESULT.labeled.tre.qc -d example/RESULT.labeled.tre.qd -i example/RESULT.labeled.tre.qi
                            -o ./example --pdfwidth 8 --pdfheight 11 --branchlength branch.length --branchsize 1 --tiplabsize 2
                            --nodepointsize 4 --qstextsize 2 --qstextvjust -0.5 --xlimmin 0 --xlimmax 0.13",
                            description = "This script is for visualization of quartetsampling outputs as the figures in its publication.")
args <- parse_args(args_parser)


# print help info for null parameter exception
if (is.null(args$qctreefile)) {    
  print_help(args_parser)    
  stop("Error:\nThe parameter -c[--qctreefile] must be supplied!", call.=FALSE)
} else if (is.null(args$qdtreefile)) {
  print_help(args_parser)
  stop("Error:\nThe parameter -d[--qdtreefile] must be supplied!", call.=FALSE)
} else if (is.null(args$qitreefile)) {
  print_help(args_parser)
  stop("Error:\nThe parameter -i[--qitreefile] must be supplied!", call.=FALSE)
}



################################################################################
## program ...
print("The visualization of QS results is running ...")
 
tr_qc <- read.tree(args$qctreefile)
tr_qd <- read.tree(args$qdtreefile)
tr_qi <- read.tree(args$qitreefile)

# process node labels of above three labeled trees
# qc tree
tree <- tr_qc
tree$node.label <- gsub("qc=", "", tree$node.label)
write.tree(tree, file = file.path(args$outpath, "tree_qc.tre"))

# qd tree
tree <- tr_qd
tree$node.label <- gsub("qd=", "", tree$node.label)
write.tree(tree, file = file.path(args$outpath, "tree_qd.tre"))

# qi tree
tree <- tr_qi
tree$node.label <- gsub("qi=", "", tree$node.label)
write.tree(tree, file = file.path(args$outpath, "tree_qi.tre"))


# read into three modified tree files for QC/QD/QI
tr_qc_m <- read.newick(file.path(args$outpath, "tree_qc.tre"), node.label = "support")
tr_qd_m <- read.newick(file.path(args$outpath, "tree_qd.tre"), node.label = "support")
tr_qi_m <- read.newick(file.path(args$outpath, "tree_qi.tre"), node.labe = "support")


# add a customized label for internode or inter-branch, i.e., qc/qd/qi
score_raw <- paste(tr_qc_m@data$support, tr_qd_m@data$support, tr_qi_m@data$support, sep = "/")
score <- gsub("NA/NA/NA", "", score_raw)
score <- gsub("NA", "-", score)

# set labeled QC tree as the main plot tree
tree <- tr_qc_m
tree@data$score <- score

# extract the internodes number without QC value, and not plot with colored circle
node_noQC <- tree@data$node[is.na(tree@data$support)]


################################################################################
# Partitioning quartet concordance. QC values were divided into four categories
# and this information was used to color circle points. 
print("Start to plot ...")



if (is.null(args$xlimmin) | is.null(args$xlimmax)) {
  # (1) in first plot, color circle points for four categories of QC.
  pdf(file = file.path(args$outpath, "plot_QC_rect.pdf"), width = args$pdfwidth, height = args$pdfheight)
  p1 <-   ggtree(tree, size = args$branchwidth, branch.length = args$branchlength) +
    geom_tiplab(size = args$tiplabsize) + 
    geom_nodepoint(aes(subset = !isTip & node != node_noQC, fill = cut(support, c(1, 0.2, 0, -0.05, -1))),
                   shape = 21, size = args$nodepointsize) +
    theme_tree(legend.position = "right") +
    scale_fill_manual(values = c("#2F4F4F", "#98F898", "#FFCC99", "#FF6600"),
                      guide = "legend", name = "Quartet Concordance",
                      breaks = c("(0.2,1]","(0,0.2]","(-0.05,0]","(-1,-0.05]"),
                      labels = expression(QC > 0.2, 0 < QC * " <= 0.2", -0.05 < QC * " <= 0", QC <= -0.05))
  print(p1)
  
  dev.off()
  
  # (2) in second plot, color branch for four categories of QC, suitable for over
  #     hundreds of tips.
  pdf(file = file.path(args$outpath, "plot_QC_circ.pdf"), width = args$pdfwidth, height = args$pdfheight)
  p2 <-   ggtree(tree, size = args$branchwidth, layout="circular", branch.length = args$branchlength,
                 aes(color = cut(support, c(1, 0.2, 0, -0.05, -1)))) +
    theme_tree(legend.position = "bottom") +
    scale_colour_manual(values = c("#2F4F4F", "#98F898", "#FFCC99", "#FF6600"),
                        breaks = c("(0.2,1]", "(0,0.2]", "(-0.05,0]", "(-1,-0.05]"),
                        na.translate = T, na.value = "gray",
                        guide = "legend", name = "Quartet Concordance",
                        labels = expression(QC > 0.2, 0 < QC * " <= 0.2", -0.05 < QC * " <= 0", QC <= -0.05)) +
    geom_tiplab(size = args$tiplabsize, colour = "black")
  
  print(p2)

  dev.off()
  
  # (3) in tird plot, color circle points for four categories of QC, and label 
  #     each internode with QC/QD/QI.
  pdf(file = file.path(args$outpath, "plot_QCQDQI_rect.pdf"), width = args$pdfwidth, height = args$pdfheight)
  p3 <-   ggtree(tree, size = args$branchwidth, branch.length = args$branchlength) +
    geom_tiplab(size = args$tiplabsize) +
    geom_nodepoint(aes(subset = !isTip & node != node_noQC, fill = cut(support, c(1, 0.2, 0, -0.05, -1))),
                   shape = 21, size = args$nodepointsize) +
    geom_text(aes(label = score, x = branch), size = args$qstextsize, vjust = args$qstextvjust) + 
    theme_tree(legend.position = "right") +
    scale_fill_manual(values = c("#2F4F4F", "#98F898", "#FFCC99", "#FF6600"),
                      guide = "legend", name = "Quartet Concordance",
                      breaks = c("(0.2,1]", "(0,0.2]", "(-0.05,0]", "(-1,-0.05]"),
                      labels = expression(QC > 0.2, 0 < QC * " <= 0.2", -0.05 < QC * " <= 0", QC <= -0.05))
  print(p3)

  dev.off()

  
## when setting the  scale limits on x-axis 
} else {
  # (1) in first plot, color circle points for four categories of QC.
  pdf(file = file.path(args$outpath, "plot_QC_rect.pdf"), width = args$pdfwidth, height = args$pdfheight)
  p1 <-   ggtree(tree, size = args$branchwidth, branch.length = args$branchlength) +
    xlim(args$xlimmin, args$xlimmax) +
    geom_tiplab(size = args$tiplabsize) + 
    geom_nodepoint(aes(subset = !isTip & node != node_noQC, fill = cut(support, c(1, 0.2, 0, -0.05, -1))),
                   shape = 21, size = args$nodepointsize) +
    theme_tree(legend.position = "right") +
    scale_fill_manual(values = c("#2F4F4F", "#98F898", "#FFCC99", "#FF6600"),
                      guide = "legend", name = "Quartet Concordance",
                      breaks = c("(0.2,1]","(0,0.2]","(-0.05,0]","(-1,-0.05]"),
                      labels = expression(QC > 0.2, 0 < QC * " <= 0.2", -0.05 < QC * " <= 0", QC <= -0.05))
  print(p1)

  dev.off()
  
  # (2) in second plot, color branch for four categories of QC, suitable for over
  #     hundreds of tips.
  pdf(file = file.path(args$outpath, "plot_QC_circ.pdf"), width = args$pdfwidth, height = args$pdfheight)
  p2 <-   ggtree(tree, size = args$branchwidth, layout="circular", branch.length = args$branchlength,
                 aes(color = cut(support, c(1, 0.2, 0, -0.05, -1)))) +
    theme_tree(legend.position = "bottom") +
    scale_colour_manual(values = c("#2F4F4F", "#98F898", "#FFCC99", "#FF6600"),
                        breaks = c("(0.2,1]", "(0,0.2]", "(-0.05,0]", "(-1,-0.05]"),
                        na.translate = T, na.value = "gray",
                        guide = "legend", name = "Quartet Concordance",
                        labels = expression(QC > 0.2, 0 < QC * " <= 0.2", -0.05 < QC * " <= 0", QC <= -0.05)) +
    geom_tiplab(size = args$tiplabsize, colour = "black")
  
  print(p2)

  dev.off()
  
  # (3) in tird plot, color circle points for four categories of QC, and label 
  #     each internode with QC/QD/QI.
  pdf(file = file.path(args$outpath, "plot_QCQDQI_rect.pdf"), width = args$pdfwidth, height = args$pdfheight)
  p3 <-   ggtree(tree, size = args$branchwidth, branch.length = args$branchlength) +
    xlim(args$xlimmin, args$xlimmax) +
    geom_tiplab(size = args$tiplabsize) +
    geom_nodepoint(aes(subset = !isTip & node != node_noQC, fill = cut(support, c(1, 0.2, 0, -0.05, -1))),
                   shape = 21, size = args$nodepointsize) +
    geom_text(aes(label = score, x = branch), size = args$qstextsize, vjust = args$qstextvjust) + 
    theme_tree(legend.position = "right") +
    scale_fill_manual(values = c("#2F4F4F", "#98F898", "#FFCC99", "#FF6600"),
                      guide = "legend", name = "Quartet Concordance",
                      breaks = c("(0.2,1]", "(0,0.2]", "(-0.05,0]", "(-1,-0.05]"),
                      labels = expression(QC > 0.2, 0 < QC * " <= 0.2", -0.05 < QC * " <= 0", QC <= -0.05))
  print(p3)

  dev.off()
}




print(paste0("The visualization of QS results is finished! Save in ", file.path(args$outpath, "plot_XXXX.pdf")))



