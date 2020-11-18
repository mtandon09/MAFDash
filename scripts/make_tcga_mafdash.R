rm(list=ls())

library(TCGAbiolinks)
library(maftools)
library(rmarkdown)
source("scripts/helper_functions/helper_functions.oncoplot.R")
source("scripts/helper_functions/helper_functions.tcga.R")


# tcga_code = "UVM"    ## Small-ish dataset
tcga_code = "BRCA" ## Large-ish dataset
caller = "mutect2"
title_label = paste0("TCGA-",tcga_code)

out_dir = file.path("output")
if(!dir.exists(out_dir)){dir.create(out_dir, recursive = T)}


maf_file <- file.path("data",paste0("TCGA_",tcga_code),caller,paste0("TCGA_",tcga_code,".",caller,".maf"))
if (!file.exists(maf_file)) {
  get_tcga_data(tcga_code,variant_caller = caller)
}

filtered_maf <- filter_maf(maf_file)

rmd_filename="scripts/MAFDash.Rmd"

html_filename=paste0(title_label,".",gsub(".Rmd",".html",basename(rmd_filename)))
rmarkdown::render(rmd_filename,
                  knit_root_dir=getwd(),
                  output_format="all", output_file=html_filename,
                  params = list(
                    maffile=maf_file,
                    titletext=title_label
                  ))

### rmarkdown::render doesn't let you select output destination (it uses the path of the Rmd file)
##  So this bit will move the report to the path in the 'out_dir' variable
if (!dir.exists(out_dir)) { dir.create(out_dir, recursive = T) }
file.rename(file.path(dirname(rmd_filename),html_filename), file.path(out_dir,html_filename))














