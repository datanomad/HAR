## Getting and Cleaning Data
## Course Project

## 1. Merge the training and the test sets to create one data set.
## 2. Extract only the measurements on the mean and standard deviation 
## for each measurement.
## 3. Use descriptive activity names to name the activities in the data set.
## 4. Appropriately label the data set with descriptive variable names.
## 5. Create a second, independent tidy data set with the average of each 
## variable for each activity and each subject.


## Test files:
X_test <- "~/UCI HAR Dataset/test/X_test.txt"
y_test <- "~/UCI HAR Dataset/test/y_test.txt"
subject_test <- "~/UCI HAR Dataset/test/subject_test.txt"

## Training files:
X_train <- "~/UCI HAR Dataset/train/X_train.txt"
y_train <- "~/UCI HAR Dataset/train/y_train.txt"
subject_train <- "~/UCI HAR Dataset/train/subject_train.txt"

## Label files:
activityfile <- "~/UCI HAR Dataset/activity_labels.txt"
featuresfile <- "~/UCI HAR Dataset/features.txt"

## Load the test and training datasets:
 testdata <- read.table(X_test, header = FALSE, sep = "")
traindata <- read.table(X_train, header = FALSE, sep = "")

## Load activity identifiers:
 ytest <- read.table(y_test, header = FALSE, sep = "")
ytrain <- read.table(y_train, header = FALSE, sep = "")

## Load subject identifiers:
 subjecttest <- read.table(subject_test, header = FALSE, sep = "")
subjecttrain <- read.table(subject_train, header = FALSE, sep = "")

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

## Merge the two data sets:
tidydata1 <- merge(tidytest2, tidytrain2, all = TRUE)

## Load measurement labels:
features <- read.table(featuresfile, header = FALSE, sep = "")

## Add labels to the tidy dataset:
tidylabels <- as.vector(features$V2)
names(tidydata1)[3:563] <- tidylabels

## Find all columns containing mean or standard deviation measurements
## and make a list of columns to extract from the tidy dataset:
n1 <- names(tidydata1)[grep("-mean()", names(tidydata1), fixed = TRUE)]
n2 <- names(tidydata1)[grep("-std()", names(tidydata1), fixed = TRUE)]
n3 <- c("subject", "activity")
extractcols <- c(n3, n1, n2)

## Extract from the dataset only the measurements on the mean and standard 
## deviation, for each feature vector for each pattern:
tidydata <- tidydata1[, extractcols]

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

## Create a second, independent tidy data set with the average of each 
## variable for each activity and each subject:
library(reshape2)
tidymelt1 <- melt(tidydata, id = n3, measure.vars=c(n1, n2))
tidydata2 <- dcast(tidymelt1, subject + activity ~ variable, mean)

## Save the dataset to a text file (in the working directory):
write.csv(tidydata2, "~/tidydata.txt", row.names = FALSE)

## Create a codebook:












