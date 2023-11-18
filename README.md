# QS_visualization
Visualization of quartetsampling outputs as the figures in its publication

Program: https://github.com/FePhyFoFum/quartetsampling

Publication: James B Pease, Joseph W Brown, Joseph F Walker, Cody E Hinchliff, Stephen A Smith. 2018. Quartet Sampling distinguishes lack of support from conflicting support in the green plant tree of life. American Journal of Botany. 105(3): 385–403. doi:10.1002/ajb2.1016

## R packages are required before running this script

In R or Rstudio Console, use following codes to check if these required packages have been installed:

        $ require(ggtree)
        $ require(treeio)
        $ require(ggplot2)
        $ require(ape)
        $ require(optparse)

If any package is not installed, you can use "install.packages()" or "devtools::install_github()" for installing.

## Usage: Rscript plot_QC_ggtree.R [options]

Run this R script in  R/Rstudio Terminal, or on the terminal of your local computer with "Rscript.exe" into environmental variable.

Run below code for help information on how to use this script, and understand its arguments.

`$ Rscript plot_QC_ggtree.R -h`

Options:

        -c QCTREEFILE, --qctreefile=QCTREEFILE
                Required, tree file with QC value labeled, that is one of outputs of QS method: default = NULL

        -d QDTREEFILE, --qdtreefile=QDTREEFILE
                Required, tree file with QD value labeled, that is one of outputs of QS method: default = NULL

        -i QITREEFILE, --qitreefile=QITREEFILE
                Required, tree file with QI value labeled, that is one of outputs of QS method: default = NULL

        -o OUTPATH, --outpath=OUTPATH
                Required, output directory: default = "./"

        --pdfwidth=PDFWIDTH
                Optional, the width of the graphics region in inches: default = 8

        --pdfheight=PDFHEIGHT
                Optional, the height of the graphics region in inches: default = 11

        --branchlength=BRANCHLENGTH
                Optional, variable for scaling branch, if "none" draw cladogram
              (that is useful when your tree has a few abnormal long branch length).
              default = "branch.length"

        --branchsize=BRANCHSIZE
                Optional, the size of tree branch: default = 1

        --tiplabsize=TIPLABSIZE
                Optional, the size of tip labels: default = 2

        --nodepointsize=NODEPOINTSIZE
                Optional, the size of node points: default = 4

        --qstextsize=QSTEXTSIZE
                Optional, the size of branch labels of three QS values (QC/QD/QI): default = 2

        --qstextvjust=QSTEXTVJUST
                Optional, vertical adjust for branch labels of three QS values (QC/QD/QI): default = -0.5

        --xlimmin=XLIMMIN
                Optional, set the min value (usually set as 0) for x axis limits specially for
              Tree panel when tip labels outside pannel. Must setted together with "--xlimmax".
              More bigger xlimmin value, more narrower (zoom out) tree plotted along x-axis, and
              vice versa (zoom in). You can use theme_tree2() for default x-axis limits. default = NULL

        --xlimmax=XLIMMAX
                Optional, set the max value for x axis limits specially for
              Tree panel when tip labels outside pannel. Must setted together with "--xlimmin".
              More bigger xlimmax value, more narrower (zoom out) tree along x-axis, and vice versa (zoom in).
              You can use theme_tree2() for default x-axis limits. default = NULL

        -h, --help
                Show this help message and exit

Totally, there are 14 arguments, the former three are mandatory required argruments (i.e., the QC, QD, and QI labeled tree files), and the remaining are optional for adjusting output path, and plotting/visualization.

## Testing, and exemplified commands
In directory "example/", quartet sampling outputs for a 188-taxon dataset of one oak clade are provided, and you can use them for testing. Some exemplified commands：

Only set parameter value for three mandatory required argruments, and use defaults for plotting argruments.

`$ Rscript plot_QC_ggtree.R -c example/RESULT.labeled.tre.qc -d example/RESULT.labeled.tre.qd -i example/RESULT.labeled.tre.qi`

Not show branch length for plotting when some abnormal long branches are presented in your tree.

`$ Rscript plot_QC_ggtree.R -c example/RESULT.labeled.tre.qc -d example/RESULT.labeled.tre.qd -i example/RESULT.labeled.tre.qi -o ./example --branchlength none`

Set proper parameter values for the size of tree branches, tip labels, node points, and custom branch labels.

`$ Rscript plot_QC_ggtree.R -c example/RESULT.labeled.tre.qc -d example/RESULT.labeled.tre.qd -i example/RESULT.labeled.tre.qi -o ./example --pdfwidth 8 --pdfheight 11 --branchlength branch.length --branchsize 2 --tiplabsize 2 --nodepointsize 4 --qstextsize 2 --qstextvjust -0.5`

When some tip labels are plotted outside panel, use "--xlimmin" and "--xlimmax" for zooming in or out.

`$ Rscript plot_QC_ggtree.R -c example/RESULT.labeled.tre.qc -d example/RESULT.labeled.tre.qd -i example/RESULT.labeled.tre.qi -o ./example --pdfwidth 8 --pdfheight 11 --branchlength branch.length --branchsize 1 --tiplabsize 2 --nodepointsize 4 --qstextsize 2 --qstextvjust -0.5 --xlimmin 0 --xlimmax 0.13`

## Marks
The original script "plot_QC_ggtree.R" was written three years ago, and is a little rough. Thanks a lot for many peoples, who use this script and report "bug" or "error" to me. With these useful feedbacks, I recently re-wrote this script, fixed known bugs, changed its usage with a command line in terminal, and added a bunch of arguments for custom plot settings for users' own dataset (with a few tips/species or over hundreds of tips/species). Any bug that you find and reported here is welcomed!   
