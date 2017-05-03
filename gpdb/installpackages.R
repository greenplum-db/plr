#!/usr/bin/env Rscript
# called with package name as arg[1]
# and destination as arg[2]
args = commandArgs(trailingOnly=TRUE)
cran = getOption("repos") 
cran["CRAN"]="https://cran.cnr.berkeley.edu"
options(repos=cran)
rm (cran)
install.packages(args[1],lib=args[2])

