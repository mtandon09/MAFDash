get_tcga_data <- function(tcga_dataset="ACC",save_folder=file.path("data"), variant_caller="mutect2") {
  
  require(TCGAbiolinks)
  
  # tcga_dataset="STAD"
  save_folder=file.path(save_folder,paste0("TCGA_",tcga_dataset),variant_caller)
  tcga_maf_file=file.path(save_folder,paste0("TCGA_",tcga_dataset,".",variant_caller,".maf"))
  
  if (!file.exists(tcga_maf_file)) {
    if(!dir.exists(save_folder)) {dir.create(save_folder, recursive = T)}
    tcga_maf <- GDCquery_Maf(gsub("TCGA-","",tcga_dataset), 
                             pipelines = variant_caller, 
                             directory = save_folder)
    tcga_maf$Tumor_Sample_Barcode_original <- tcga_maf$Tumor_Sample_Barcode
    tcga_maf$Tumor_Sample_Barcode <-unlist(lapply(strsplit(tcga_maf$Tumor_Sample_Barcode, "-"), function(x) {paste0(x[1:3], collapse="-")}))
    tcga_maf$caller <- variant_caller
    write.table(tcga_maf, file=tcga_maf_file, quote=F, sep="\t", row.names = F, col.names = T)
  }
  
  
  tcga_clinical_file=file.path(save_folder,paste0("TCGA_",tcga_dataset,".clinical.txt"))
  if (! file.exists(tcga_clinical_file)) {
    if (!dir.exists(dirname(tcga_clinical_file))) {dir.create(dirname(tcga_clinical_file), recursive = T)}
    tcga_clinical <- GDCquery_clinic(project = paste0("TCGA-",tcga_dataset), type = "clinical")
    write.table(tcga_clinical, file=tcga_clinical_file, quote=T, sep="\t", row.names = F, col.names = T)
  }
  
  
  tcga_clin_data <- read.table(tcga_clinical_file, sep="\t",header = T,stringsAsFactors = F)
  tcga_clin_data$Tumor_Sample_Barcode <- tcga_clin_data$bcr_patient_barcode
  tcga_maf <- read.maf(tcga_maf_file, clinicalData = tcga_clin_data)
  
  # return(list(mafObj=tcga_maf, clindat=tcga_clin_data))
  return(tcga_maf)
  
}


make_tcga_clinical_annotation <- function(tcga_maf_obj, plotdata=NULL) {
  require(maftools)
  require(RColorBrewer)
  require(ComplexHeatmap)
  require(circlize)
  tcga_clin_data <- tcga_maf_obj@clinical.data
  tcga_pheno_columns <- c("Tumor_Sample_Barcode","ajcc_pathologic_stage","age_at_diagnosis","gender","race","vital_status","tissue_or_organ_of_origin")
  matched_order=1:nrow(tcga_clin_data)
  if (!is.null(plotdata)) {
    matched_order=match(colnames(plotdata), tcga_clin_data$Tumor_Sample_Barcode, nomatch=0)
  } 
  tcga_anno_data <- tcga_clin_data[matched_order,..tcga_pheno_columns]
  tcga_dataset <- paste0(unique(tcga_clin_data$disease), collapse=",")
  tcga_anno_data$Dataset <- tcga_dataset

  anno_data <- tcga_anno_data

  stages=sort(unique(anno_data$ajcc_pathologic_stage))
  stage_colors <- setNames(brewer.pal(n = length(stages), name = "Reds"), stages)
  
  anno_data$age_at_diagnosis <- as.numeric(as.character(anno_data$age_at_diagnosis))
  age_range=round(range(anno_data$age_at_diagnosis, na.rm = T),-1)
  age_color_length=10
  age_breaks=round(seq(age_range[1], age_range[2], length.out=age_color_length),0)
  age_color_vals=colorRampPalette(c("lightblue1","royalblue1","navy"))(age_color_length)
  age_colors=colorRamp2(age_breaks, age_color_vals)
  
  gender_colors=c(female="hotpink", male="cornflowerblue")
  
  races=sort(unique(anno_data$race))
  race_colors <- setNames(rev(brewer.pal(n = length(races), name = "Set1")), races)
  
  statuses=sort(unique(anno_data$vital_status))
  vitstat_colors <- c(Alive="darkgreen",Dead="darkred")
  
  tissues=sort(unique(anno_data$tissue_or_organ_of_origin))
  tissue_colors <- setNames(brewer.pal(n = length(tissues), name = "Dark2"), tissues)
  
  # dataset_colors <- setNames(c("mediumorchid1","darkolivegreen1"),
  dataset_colors <- setNames(c("grey30","darkolivegreen1"),
                             c(tcga_dataset, "Other"))
  
  anno_colors <- setNames(list(stage_colors, age_colors, gender_colors, race_colors, vitstat_colors, tissue_colors, dataset_colors),
                          setdiff(colnames(anno_data),"Tumor_Sample_Barcode"))
  
  
  mycols <- which(!colnames(anno_data) %in% c("Tumor_Sample_Barcode"))
  anno_df <- anno_data[,..mycols]
  myanno <- HeatmapAnnotation(df=anno_df,col = anno_colors)
  
  return(list(colorList=anno_colors, annodata=anno_data, HManno=myanno))
  
}