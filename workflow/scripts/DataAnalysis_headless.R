# Extract data from "3D_Dist Cellprofiler" output

if (!require("tcltk")) install.packages('tcltk', repos = "https://cran.rstudio.com/")
if (!require("readr")) install.packages('readr', repos = "https://cran.rstudio.com/")
if (!require("dplyr")) install.packages('dplyr', repos = "https://cran.rstudio.com/")
if (!require("usedist")) install.packages('usedist', repos = "https://cran.rstudio.com/")
if (!require("tidyr")) install.packages('tidyr', repos = "https://cran.rstudio.com/")
if (!require("writexl")) install.packages('writexl', repos = "https://cran.rstudio.com/")

library(tcltk)
library(readr)
library(dplyr)
library(usedist)
library(tidyr)
library(writexl)


# Get command arguments
args = commandArgs(trailingOnly=TRUE)

# test if there are two arguments: if not, return an error
if (length(args)!=2) {
  stop("Two arguments must be supplied!", call.=FALSE)
}

# Specify the file paths
dirPath <- args[1]

# Specify image scale
IMAGESCALE <- as.numeric(args[2])
  
# Load "Nuclei.csv" file  and create the dataframe
file_nuclei <- file.path(dirPath, "Nuclei.csv")
df_nuclei <- read.csv(file_nuclei)
df_nuclei <- df_nuclei %>% arrange(ImageNumber, ObjectNumber) # sorting

# Load "Filter_RED.csv" file  and create the dataframe
file_RED <- file.path(dirPath, "Filter_RED.csv")
df_RED <- read.csv(file_RED)
df_RED <- df_RED %>% arrange(ImageNumber, Parent_Nuclei) # sorting

# Load "Filter_GREEN.csv" file  and create the dataframe
file_GREEN <- file.path(dirPath, "Filter_GREEN.csv")
df_GREEN <- read.csv(file_GREEN)
df_GREEN <- df_GREEN %>% arrange(ImageNumber, Parent_Nuclei) # sorting

# Load "NucleiCenter.csv" file  and create the data frame
file_NucleiCenter <- file.path(dirPath, "NucleiCenter.csv")
df_NucleiCenter <- read.csv(file_NucleiCenter)
df_NucleiCenter <- df_NucleiCenter %>% arrange(ImageNumber, 
                                               Parent_Nuclei) # sort dataframe

# Index from "df_nuclei" dataframe where the condition of there is 2 RED and 
# 2 GREEN markers per nucleus is meet
idx = (df_nuclei$Children_Filter_RED_Count == 2) & 
       (df_nuclei$Children_Filter_GREEN_Count == 2) 

# Extract Parent_Nuclei id and ImageNumber id from "df_nuclei" dataframe
# according to the rule of 2 RED and GREEN marker per nucleus.
# Create a df_Selection dataframe
Parent_Nuclei = df_nuclei$ObjectNumber[idx]
ImageNumber = df_nuclei$ImageNumber[idx]
df_Selection <- data.frame(cbind(ImageNumber, Parent_Nuclei))

# Create dataframe of NucleiCenter based on the above selection rule
Parent_Nuclei <- df_NucleiCenter$Parent_Nuclei
ImageNumber <- df_NucleiCenter$ImageNumber
Distance_Minimum_Nuclei <- df_NucleiCenter$Distance_Minimum_Nuclei
df_Selection_NucleiDist <- data.frame(cbind(ImageNumber, 
                                            Parent_Nuclei, 
                                            Distance_Minimum_Nuclei))

# Apply the selection rule to RED dataset
df_Selection$Marker <- "RED"
df <- merge(df_RED, df_Selection)
df <- df %>% arrange(ImageNumber, Parent_Nuclei) 
df <- select(df, -c(FileName_DAPI,
                    FileName_red,
                    PathName_DAPI,
                    PathName_red))

df <- merge(df, 
            df_Selection_NucleiDist, 
            by.x = cbind("ImageNumber","Parent_Nuclei"), 
            by.y = cbind("ImageNumber","Parent_Nuclei"))

df$Norm_Dist <- df$Distance_Minimum_Nuclei.x/
               df$Distance_Minimum_Nuclei.y

df <- select(df, -Distance_Minimum_Nuclei.y)

df$Distance_Minimum_Nuclei.x <- df$Distance_Minimum_Nuclei.x *IMAGESCALE # Add scale

RED <- rename(df,
                FileName = FileName_green,
                PathName = PathName_green,
                Min_Dist2Surf = Distance_Minimum_Nuclei.x)

# Apply the selection rule to GREEN dataset
df_Selection$Marker <- "GREEN"
df <- merge(df_GREEN, df_Selection)
df <- df %>% arrange(ImageNumber, Parent_Nuclei)
df <- select(df, -c(FileName_DAPI,
                    FileName_green,
                    PathName_DAPI,
                    PathName_green))

df <- merge(df, 
            df_Selection_NucleiDist, 
            by.x = cbind("ImageNumber","Parent_Nuclei"), 
            by.y = cbind("ImageNumber","Parent_Nuclei"))

df$Norm_Dist <- df$Distance_Minimum_Nuclei.x/
               df$Distance_Minimum_Nuclei.y

df <- select(df, -Distance_Minimum_Nuclei.y)

df$Distance_Minimum_Nuclei.x <- df$Distance_Minimum_Nuclei.x *IMAGESCALE # Add scale

GREEN <- rename(df,
                FileName = FileName_red,
                PathName = PathName_red,
                Min_Dist2Surf = Distance_Minimum_Nuclei.x)

# Join row-wise dataframe RED and GREEN
Results_Markers <- rbind(RED, GREEN) %>% 
                   arrange(ImageNumber, Parent_Nuclei) # sorting

v <- rep(1:2,nrow(Results_Markers)/2)
Results_Markers$idx <- v
Results_Markers$Marker <- paste(Results_Markers$Marker, 
                                Results_Markers$idx, sep=".")

Results_Markers <- Results_Markers %>% select(-idx)
                                      

# Distance matrix calculation
df_Distances <- Results_Markers %>% 
                group_by(ImageNumber, 
                         Parent_Nuclei) %>% 
                summarise(distmatrix=list(dist_setNames(dist(cbind(Location_Center_X*IMAGESCALE, 
                                                                   Location_Center_Y*IMAGESCALE, 
                                                                   Location_Center_Z*IMAGESCALE)),
                                                                   c("RED_1",
                                                                     "RED_2", 
                                                                     "GREEN_1",
                                                                     "GREEN_2"))), 
                                                                   .groups = "keep")



# Distance matrix column separeted representation
data <- unlist(df_Distances$distmatrix) %>% 
        matrix(ncol = 6, byrow = TRUE)

df_data <- data.frame(data)
df_Distances_Details <- cbind(df_Distances[,c(1,2)], df_data) %>%
                        rename(RED.1_RED.2 = X1,
                               RED.1_GREEN.1 = X2,
                               RED.1_GREEN.2 = X3,
                               RED.2_GREEN.1 = X4,
                               RED.2_GREEN.2 = X5,
                               GREEN.1_GREEN.2 = X6)


# Distance Final results
df <- merge(df_nuclei, 
            df_Distances_Details, 
            by.x = cbind("ImageNumber","ObjectNumber"), 
            by.y = cbind("ImageNumber","Parent_Nuclei"))


df$AreaShape_EquivalentDiameter <- df$AreaShape_EquivalentDiameter*IMAGESCALE # Add scale

df <- df %>% select(-c(FileName_green,
                    FileName_red,
                    PathName_green,
                    PathName_red,
                    Children_Filter_RED_Count,
                    Children_Filter_GREEN_Count,
                    AreaShape_Volume
                    )) %>%
            rename(Nucleus_ID = ObjectNumber,
                   EquivalentDiameter = AreaShape_EquivalentDiameter)

df$Min_Dist = names(df[,10:14])[apply(df[,10:14], 
                                      MARGIN = 1, 
                                      FUN = which.min)]

df <- df %>% arrange(ImageNumber, Nucleus_ID) # sorting
Results_Nuclei <- df


# Save results
Results_Markers <- Results_Markers %>% 
                   rename(Nucleus_ID = Parent_Nuclei) %>%
                   select(-ObjectNumber) %>%
                   select(ImageNumber,
                          Nucleus_ID,
                          FileName,
                          PathName,
                          Location_Center_X,
                          Location_Center_Y,
                          Location_Center_Z,
                          Min_Dist2Surf,
                          Norm_Dist,
                          Marker
                   )%>% 
                   arrange(ImageNumber, Nucleus_ID)

Results_Markers_file <- file.path(dirPath, "Results_in_um_Markers.xlsx")
Results_Markers_file_csv <- file.path(dirPath, "Results_in_um_Markers.csv")
Results_Nuclei_file <- file.path(dirPath, "Results_in_um_Nuclei.xlsx")
Results_Nuclei_file_csv <- file.path(dirPath, "Results_in_um_Nuclei.csv")
write_xlsx(Results_Markers, Results_Markers_file)
write_xlsx(Results_Nuclei, Results_Nuclei_file)
write.csv(Results_Markers, Results_Markers_file_csv, row.names=FALSE)
write.csv(Results_Nuclei, Results_Nuclei_file_csv, row.names=FALSE)






