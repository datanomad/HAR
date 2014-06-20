# README.md

## Introduction
This readme file explains how the script contained in the file `run_analysis.R` works.  

The script was used to *tidy* (i.e. prepare for analysis) data collected from the accelerometers of Samsung Galaxy S II smartphones, during a study involving 30 subjects who performed six activities (walking, walking upstairs, walking downstairs, sitting, standing or laying down) while wearing the smartphone on the waist.  

## Getting and cleaning the data

The dataset was originally obtained from this website: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones.  

The data, subject and activity identifiers, activity labels, measurement descriptions and other information, are provided in separate files. **Note:** In the script it is assumed that the files are available in the working directory (in this case, `~/data`).  

### Defining file path variables (to keep the code compact):

```r
## Test files:
       X_test <- "~/data/UCI HAR Dataset/test/X_test.txt"
       y_test <- "~/data/UCI HAR Dataset/test/y_test.txt"
 subject_test <- "~/data/UCI HAR Dataset/test/subject_test.txt"

## Training files:
      X_train <- "~/data/UCI HAR Dataset/train/X_train.txt"
      y_train <- "~/data/UCI HAR Dataset/train/y_train.txt"
subject_train <- "~/data/UCI HAR Dataset/train/subject_train.txt"

## Label files:
 activityfile <- "~/data/UCI HAR Dataset/activity_labels.txt"
 featuresfile <- "~/data/UCI HAR Dataset/features.txt"
```


### Loading the test and training datasets:

```r
 testdata <- read.table(X_test, header = FALSE, sep = "")
traindata <- read.table(X_train, header = FALSE, sep = "")
```

### Loading the activity and subject identifiers:

```r
       ytest <- read.table(y_test, header = FALSE, sep = "")
      ytrain <- read.table(y_train, header = FALSE, sep = "")
 subjecttest <- read.table(subject_test, header = FALSE, sep = "")
subjecttrain <- read.table(subject_train, header = FALSE, sep = "")
```

### Adding activity and subject data to the datasets:

```r
## Add activity ids to the datasets:
 tidytest1 <- cbind(ytest$V1, testdata)
tidytrain1 <- cbind(ytrain$V1, traindata)

## Add a descriptive name to the new column:
 names(tidytest1)[1] <- "activity"
names(tidytrain1)[1] <- "activity"

## Add subject identifiers to the datasets:
 tidytest2 <- cbind(subjecttest$V1, tidytest1)
tidytrain2 <- cbind(subjecttrain$V1, tidytrain1)

## Add a descriptive name to the new column:
 names(tidytest2)[1] <- "subject"
names(tidytrain2)[1] <- "subject"
```

### Merging the training and the test sets to create a single dataset:

```r
tidydata1 <- merge(tidytest2, tidytrain2, all = TRUE)
```

### Getting and adding measurement labels to the merged dataset:

```r
## Load measurement labels:
features <- read.table(featuresfile, header = FALSE, sep = "")

## Add labels to the tidy dataset:
tidylabels <- as.vector(features$V2)
names(tidydata1)[3:563] <- tidylabels
```

### Extracting only the measurements on the mean and standard deviation, for each measurement:

```r
## Find all columns containing mean or standard deviation measurements
## and make a list of columns to extract from the tidy dataset:
n1 <- names(tidydata1)[grep("-mean()", names(tidydata1), fixed = TRUE)]
n2 <- names(tidydata1)[grep("-std()", names(tidydata1), fixed = TRUE)]
n3 <- c("subject", "activity")
extractcols <- c(n3, n1, n2)

## Extract from the dataset only the measurements on the mean and standard 
## deviation:
tidydata <- tidydata1[, extractcols]
```

### Using descriptive activity names for the activities in the dataset:

```r
## Load descriptive activity names:
activitynames <- read.table(activityfile, header = FALSE, sep = "")

## Add descriptive activity names:
for(i in 1:6) {
    for(r in 1:nrow(tidydata)) {
        if(tidydata[r, 2]==activitynames[i, 1]) {
            tidydata[r, 2] <- as.character(activitynames[i, 2])
        }
        else { next(r) }
    }
}
```

### Appropriately labelling the data set with descriptive variable names:

```r
## pending
```

### Creating a second dataset with the average of each variable for each activity and each subject:

```r
## reshape2 is required:
library(reshape2)

## The second dataset is created by melting the data and re-casting it:
tidymelt1 <- melt(tidydata, id = n3, measure.vars=c(n1, n2))
tidydata2 <- dcast(tidymelt1, subject + activity ~ variable, mean)

## Save the dataset to a text file (in the working directory):
write.csv(tidydata2, "~/data/tidydata.txt", row.names = FALSE)
```

