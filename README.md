#### View on [github.io](https://mtandon09.github.io/MAFDash/)
# MAFDash
*Cuz once you've called the variants, it's a MAF dash to the finish line*

## Example
Here are some example dashboards created using TCGA data:
- [TCGA-UVM](output/UVM/TCGA-UVM.MAFDash.html)
- [TCGA-BRCA](output/BRCA/TCGA-BRCA.MAFDash.html)

## Scope
[Mutation Annotation Format (MAF)](https://docs.gdc.cancer.gov/Encyclopedia/pages/Mutation_Annotation_Format/) is a tabular data format used for storing genetic mutation data. For example, [The Cancer Genome Atlas (TCGA)](https://www.cancer.gov/about-nci/organization/ccg/research/structural-genomics/tcga) project has made MAF files from each project publicly available.

This repo -- **MAFDash** -- contains a set of R tools to easily create an HTML dashboard to summarize and visualize data from MAF file.

The resulting HTML file serves as a self-contained report that can be used to explore the result.  Currently, MAFDash produces mostly static plots powered by [maftools](https://bioconductor.org/packages/release/bioc/vignettes/maftools/inst/doc/maftools.html),  [ComplexHeatmap](https://github.com/jokergoo/ComplexHeatmap) and [circlize](https://github.com/jokergoo/circlize), as well as interactive visualizations using [canvasXpress](https://cran.r-project.org/web/packages/canvasXpress/vignettes/getting_started.html) and [plotly](https://plotly.com/r/).  The report is generated with a parameterized [R Markdown](https://rmarkdown.rstudio.com/) script that uses [flexdashboard](https://rmarkdown.rstudio.com/flexdashboard/) to arrange all the information. I hope to add more interactivity 

This repo is a companion to a Shiny app I made, [MAFWiz](https://github.com/mtandon09/mafwiz).  Instead of relying on a Shiny server, this dashboard is an attempt to try some of those things using client-side javascript functionality.

## Making a MAFDash
The `MAFDash.Rmd` file can be rendered in R using the `rmarkdown` library like this:

```
# MAF data
maf_file="/path/to/maf/file"

# [Optional] A string to use as a title for the dashboard
title_label="My Title for the MAF Report"

# Path to the Rmd script
rmd_filename="scripts/MAFDash.Rmd"

# Make a filename for the output HTML
html_filename=gsub(".Rmd",".html",basename(rmd_filename))

# Render the report
rmarkdown::render(rmd_filename,
                  knit_root_dir=getwd(),
                  output_format="all", output_file=html_filename,
                  params = list(
                    maffile=maf_file,
                    titletext=title_label
                  ))
```
### Details
- `maf_file` can be anything that's accepted by maftools's [`read.maf`](https://rdrr.io/bioc/maftools/man/read.maf.html) function (path to a file, or a `MAF` , `data.frame`, or `data.table` object)
- The `make_tcga_maf.R` script contains a full example of how to render the Rmd file.

## Required libraries
Here's some code that will try to install required libraries that are not already installed (from [my Gist](https://gist.github.com/mtandon09/4a870bf4addbe46e784059bce0e5d8d6) about this)

```
all_pkgs<-c("rmarkdown", 
            "knitr",
            "flexdashboard",
            "htmltools",
            "DT",
            "bsplus",
            "crosstalk",
            "plotly",
            "canvasXpress",
            "maftools",
            "dplyr",
            "ComplexHeatmap",
            "circlize",
            "RColorBrewer",
            "ggbeeswarm")
            
### Figure out which ones are available in Bioconductor and install any new that are not already present
bioc_universe <- BiocManager::available()
bioc_packages <- intersect(bioc_universe, pkglist)
print(paste0(length(bioc_packages), " of ", length(pkglist), " packages found in Bioconductor."))
bioc_packages <- bioc_packages[!(bioc_packages %in% installed.packages()[,"Package"])]
print(paste0("Installing ",length(bioc_packages), " new packages from Bioconductor..."))
if(length(bioc_packages)) BiocManager::install(bioc_packages)

### Figure out which ones are available in CRAN and install any new that are not already present
cran_universe <- available.packages(repos="https://cloud.r-project.org")[,"Package"]
cran_packages <- intersect(cran_universe, pkglist)
print(paste0(length(cran_packages), " of ", length(pkglist), " packages found in CRAN."))
cran_packages <- cran_packages[!(cran_packages %in% installed.packages()[,"Package"])]
print(paste0("Installing ",length(cran_packages), " new packages from CRAN..."))
if(length(cran_packages)) install.packages(cran_packages, repos="https://cloud.r-project.org")
```
#### Session Info
I've created and tested this using R 3.6.2.  Here's the complete `sessionInfo`

```
R version 3.6.2 (2019-12-12)
Platform: x86_64-apple-darwin15.6.0 (64-bit)
Running under: macOS Mojave 10.14.6

Matrix products: default
BLAS:   /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libBLAS.dylib
LAPACK: /Library/Frameworks/R.framework/Versions/3.6/Resources/lib/libRlapack.dylib

locale:
[1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8

attached base packages:
[1] grid      stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] ggbeeswarm_0.6.0     circlize_0.4.11      RColorBrewer_1.1-2   ComplexHeatmap_2.2.0 canvasXpress_1.29.6  TCGAbiolinks_2.14.1 
 [7] maftools_2.2.10      knitr_1.30           bsplus_0.1.2         htmltools_0.5.0      DT_0.16              flexdashboard_0.5.2 
[13] crosstalk_1.1.0.1    dplyr_1.0.2          plotly_4.9.2.1       ggplot2_3.3.2       

loaded via a namespace (and not attached):
  [1] R.utils_2.10.1              tidyselect_1.1.0            RSQLite_2.2.1               AnnotationDbi_1.48.0       
  [5] htmlwidgets_1.5.2           BiocParallel_1.20.1         DESeq_1.38.0                munsell_0.5.0              
  [9] codetools_0.2-18            withr_2.3.0                 colorspace_1.4-1            Biobase_2.46.0             
 [13] rstudioapi_0.12             stats4_3.6.2                ggsignif_0.6.0              labeling_0.4.2             
 [17] GenomeInfoDbData_1.2.2      hwriter_1.3.2               KMsurv_0.1-5                parsetools_0.1.3           
 [21] bit64_4.0.5                 downloader_0.4              vctrs_0.3.4                 generics_0.1.0             
 [25] xfun_0.19                   ggthemes_4.2.0              BiocFileCache_1.10.2        EDASeq_2.20.0              
 [29] R6_2.5.0                    doParallel_1.0.16           GenomeInfoDb_1.22.1         clue_0.3-57                
 [33] locfit_1.5-9.4              bitops_1.0-6                DelayedArray_0.12.3         assertthat_0.2.1           
 [37] promises_1.1.1              scales_1.1.1                beeswarm_0.2.3              gtable_0.3.0               
 [41] sva_3.34.0                  rlang_0.4.8                 pkgcond_0.1.0               genefilter_1.68.0          
 [45] GlobalOptions_0.1.2         splines_3.6.2               rtracklayer_1.46.0          rstatix_0.6.0              
 [49] lazyeval_0.2.2              wordcloud_2.6               selectr_0.4-2               broom_0.7.2                
 [53] BiocManager_1.30.10         yaml_2.2.1                  reshape2_1.4.4              abind_1.4-5                
 [57] GenomicFeatures_1.38.2      backports_1.2.0             httpuv_1.5.4                purrrogress_0.1.1          
 [61] tools_3.6.2                 ellipsis_0.3.1              BiocGenerics_0.32.0         Rcpp_1.0.5                 
 [65] plyr_1.8.6                  progress_1.2.2              zlibbioc_1.32.0             purrr_0.3.4                
 [69] RCurl_1.98-1.2              prettyunits_1.1.1           ggpubr_0.4.0                openssl_1.4.3              
 [73] GetoptLong_1.0.4            S4Vectors_0.24.4            zoo_1.8-8                   cluster_2.1.0              
 [77] SummarizedExperiment_1.16.1 haven_2.3.1                 ggrepel_0.8.2               magrittr_1.5               
 [81] data.table_1.13.2           openxlsx_4.2.3              survminer_0.4.8             matrixStats_0.57.0         
 [85] aroma.light_3.16.0          hms_0.5.3                   mime_0.9                    evaluate_0.14              
 [89] xtable_1.8-4                XML_3.99-0.3                rio_0.5.16                  jpeg_0.1-8.1               
 [93] readxl_1.3.1                shape_1.4.5                 IRanges_2.20.2              gridExtra_2.3              
 [97] testthat_3.0.0              compiler_3.6.2              biomaRt_2.42.1              tibble_3.0.4               
[101] crayon_1.3.4                R.oo_1.24.0                 mgcv_1.8-33                 later_1.1.0.1              
[105] tidyr_1.1.2                 geneplotter_1.64.0          postlogic_0.1.0.1           lubridate_1.7.9            
[109] DBI_1.1.0                   dbplyr_2.0.0                rappdirs_0.3.1              ShortRead_1.44.3           
[113] Matrix_1.2-18               car_3.0-10                  readr_1.4.0                 cli_2.1.0                  
[117] R.methodsS3_1.8.1           parallel_3.6.2              GenomicRanges_1.38.0        forcats_0.5.0              
[121] pkgconfig_2.0.3             km.ci_0.5-2                 GenomicAlignments_1.22.1    foreign_0.8-76             
[125] testextra_0.1.0.1           xml2_1.3.2                  foreach_1.5.1               annotate_1.64.0            
[129] vipor_0.4.5                 XVector_0.26.0              rvest_0.3.6                 stringr_1.4.0              
[133] digest_0.6.27               Biostrings_2.54.0           rmarkdown_2.5               cellranger_1.1.0           
[137] survMisc_0.5.5              edgeR_3.28.1                curl_4.3                    shiny_1.5.0                
[141] Rsamtools_2.2.3             rjson_0.2.20                lifecycle_0.2.0             nlme_3.1-150               
[145] jsonlite_1.7.1              carData_3.0-4               viridisLite_0.3.0           askpass_1.1                
[149] limma_3.42.2                fansi_0.4.1                 pillar_1.4.6                lattice_0.20-41            
[153] fastmap_1.0.1               httr_1.4.2                  survival_3.2-7              glue_1.4.2                 
[157] zip_2.1.1                   png_0.1-7                   iterators_1.0.13            bit_4.0.4                  
[161] stringi_1.5.3               blob_1.2.1                  latticeExtra_0.6-29         memoise_1.1.0              
```



