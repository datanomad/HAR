# README.md

## Introduction
This readme file explains how the script contained in the file `run_analysis.R` works.  

The script was used to _tidy_ (i.e. prepare for analysis) data collected from the accelerometers of Samsung Galaxy S II smartphones, during a study[1] involving 30 subjects who performed six activities (walking, walking upstairs, walking downstairs, sitting, standing or laying down) while wearing the smartphone on the waist.  

[1] _Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. **Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine.** International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012._

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

### Creating a second dataset with the average of each variable for each activity and each subject:

```r
## reshape2 is required:
library(reshape2)

## The second dataset is created by melting the merged dataset and then
## re-casting it into a data frame:
tidymelt1 <- melt(tidydata, id = n3, measure.vars=c(n1, n2))
tidydata2 <- dcast(tidymelt1, subject + activity ~ variable, mean)

## The "tidy" dataset is then saved to a text file (in the working directory):
write.csv(tidydata2, "~/data/tidydata.txt", row.names = FALSE)
```

**Note:** By writing the dataset into a text file using `write.csv`, the `activity` variable was coerced into a factor with 6 levels (one per activity):  

```r
## Structure of the activity variable *before* writing the dataset into a text file:
str(tidydata2$activity)
```

```
##  chr [1:180] "LAYING" "SITTING" "STANDING" "WALKING" ...
```

```r
## and *after* writing the dataset into a text file:
tdfile <- read.csv("~/data/tidydata.txt")
str(tdfile$activity)
```

```
##  Factor w/ 6 levels "LAYING","SITTING",..: 1 2 3 4 5 6 1 2 3 4 ...
```

Additionally, any "-", "(", or ")" characters in the original variable names, were replaced with a "." character. This transformation is useful to avoid needing backquotes to select variable names.  

For example:  

```r
names(tidydata2[3])
```

```
## [1] "tBodyAcc-mean()-X"
```
becomes:  

```r
names(tdfile[3])
```

```
## [1] "tBodyAcc.mean...X"
```

### Appropriately labelling the data set with descriptive variable names:
No additional efforts were made to make the variable names more descriptive. The reason is that the original approach already results in compact variable names that are descriptive enough, following a few simple rules described in the original dataset documentation (`features_info.txt`). Here is an extract from that file, including a short description of each _particle_ used to form the variable names:

The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate.  
1. **t** prefix denotes a time domain signal  
2. **Acc** indicates that the measurement comes from the Accelerometer  
3. **Gyro** indicates that the measurement comes from the Gyroscope  
4. **.X**, **.Y**, or **.Z** suffix represents the axis (i.e. the direction) of the measured movement  

Then they were filtered to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ).  
5. **Body** indicates that the signal is attributed to body acceleration  
6. **Gravity** indicates that the signal is attributed to gravity acceleration  

Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ).  
7. **Jerk** indicates that the signal is attributed to a quick, sharp, sudden movement (i.e. a jerk)  

Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag).  
8. **Mag** denotes a signal magnitude  

A Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals).  
9. **f** prefix denotes a frequency domain signal  

A set of 561 variables were estimated from the measured signals. 66 variables of interest are preserved in the tidy dataset. They contain a particle indicating the computation that the variable represents:  
10. **.mean..** indicates that the variable contains a mean value  
11. **.std..** indicates that the variable contains a standard deviation value  

Below is a list containing the resulting variable names used in the tidy dataset, following the naming conventions described above:  

```
   Tidy dataset variable names
1            tBodyAcc.mean...X
2            tBodyAcc.mean...Y
3            tBodyAcc.mean...Z
4         tGravityAcc.mean...X
5         tGravityAcc.mean...Y
6         tGravityAcc.mean...Z
7        tBodyAccJerk.mean...X
8        tBodyAccJerk.mean...Y
9        tBodyAccJerk.mean...Z
10          tBodyGyro.mean...X
11          tBodyGyro.mean...Y
12          tBodyGyro.mean...Z
13      tBodyGyroJerk.mean...X
14      tBodyGyroJerk.mean...Y
15      tBodyGyroJerk.mean...Z
16          tBodyAccMag.mean..
17       tGravityAccMag.mean..
18      tBodyAccJerkMag.mean..
19         tBodyGyroMag.mean..
20     tBodyGyroJerkMag.mean..
21           fBodyAcc.mean...X
22           fBodyAcc.mean...Y
23           fBodyAcc.mean...Z
24       fBodyAccJerk.mean...X
25       fBodyAccJerk.mean...Y
26       fBodyAccJerk.mean...Z
27          fBodyGyro.mean...X
28          fBodyGyro.mean...Y
29          fBodyGyro.mean...Z
30          fBodyAccMag.mean..
31  fBodyBodyAccJerkMag.mean..
32     fBodyBodyGyroMag.mean..
33 fBodyBodyGyroJerkMag.mean..
34            tBodyAcc.std...X
35            tBodyAcc.std...Y
36            tBodyAcc.std...Z
37         tGravityAcc.std...X
38         tGravityAcc.std...Y
39         tGravityAcc.std...Z
40        tBodyAccJerk.std...X
41        tBodyAccJerk.std...Y
42        tBodyAccJerk.std...Z
43           tBodyGyro.std...X
44           tBodyGyro.std...Y
45           tBodyGyro.std...Z
46       tBodyGyroJerk.std...X
47       tBodyGyroJerk.std...Y
48       tBodyGyroJerk.std...Z
49           tBodyAccMag.std..
50        tGravityAccMag.std..
51       tBodyAccJerkMag.std..
52          tBodyGyroMag.std..
53      tBodyGyroJerkMag.std..
54            fBodyAcc.std...X
55            fBodyAcc.std...Y
56            fBodyAcc.std...Z
57        fBodyAccJerk.std...X
58        fBodyAccJerk.std...Y
59        fBodyAccJerk.std...Z
60           fBodyGyro.std...X
61           fBodyGyro.std...Y
62           fBodyGyro.std...Z
63           fBodyAccMag.std..
64   fBodyBodyAccJerkMag.std..
65      fBodyBodyGyroMag.std..
66  fBodyBodyGyroJerkMag.std..
```

For more details about the data structure, please refer to the tidy data code book (i.e. `CodeBook.md`).
