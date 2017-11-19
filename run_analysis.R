####################################################################################
# Script created by Rigoberto Alvarez (rigoberto.alvarez@gmail.com)
# Subject: Peer-graded Assignment: Getting and Cleaning Data Course Project
# Part of the Data Science Specialization @ JHU
####################################################################################

# Initialization and useful variables

library(dplyr)
rm(list = ls())
if(!file.exists("./data")) {
    dir.create("./data")
}
zippedDataSetsUrL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(zippedDataSetsUrL, destfile="./data/zippedDataSets.zip")
unzip(zipfile = "./data/zippedDataSets.zip", exdir = "./data", overwrite = T)
unzippedDataSetsPath <- "./data/UCI HAR Dataset/"

# 1. Merge the training and the test sets to create one data set.

# 1.1 Partial datasets

# 1.1.1 Label datasets

featuresDataSetPath <- paste(unzippedDataSetsPath, "features.txt", sep = "")
featuresDataSet <- read.table(file = featuresDataSetPath, stringsAsFactors = F)
names(featuresDataSet) <- c("feature.id", "feature.name")

activityLabelsDataSetPath <- paste(unzippedDataSetsPath, "activity_labels.txt", sep = "")
activityLabelsDataSet <- read.table(file = activityLabelsDataSetPath)
names(activityLabelsDataSet) <- c("activity.id", "activity.name")

# 1.1.2 Test datasets

subjectTestDataSetPath <- paste(unzippedDataSetsPath, "test/subject_test.txt", sep = "")
subjectTestDataSet <- read.table(file = subjectTestDataSetPath)
names(subjectTestDataSet) <- c("subject.id")

activityTestDataSetPath <- paste(unzippedDataSetsPath, "test/y_test.txt", sep = "")
activityTestDataSet <- read.table(file = activityTestDataSetPath)
names(activityTestDataSet) <- c("activity.id")

testDataSetPath <- paste(unzippedDataSetsPath, "test/X_test.txt", sep = "")
testDataSet <- read.table(file = testDataSetPath)
names(testDataSet) <- featuresDataSet$feature.name

# 1.1.3 Train datasets

subjectTrainDataSetPath <- paste(unzippedDataSetsPath, "train/subject_train.txt", sep = "")
subjectTrainDataSet <- read.table(file = subjectTrainDataSetPath)
names(subjectTrainDataSet) <- c("subject.id")

activityTrainDataSetPath <- paste(unzippedDataSetsPath, "train/y_train.txt", sep = "")
activityTrainDataSet <- read.table(file = activityTrainDataSetPath)
names(activityTrainDataSet) <- c("activity.id")

trainDataSetPath <- paste(unzippedDataSetsPath, "train/X_train.txt", sep = "")
trainDataSet <- read.table(file = trainDataSetPath)
names(trainDataSet) <- featuresDataSet$feature.name

# 1.2 Build complete test dataset: original test dataset + test subject data set + test activity data set 

completeTestDataSet <- cbind(subjectTestDataSet, activityTestDataSet, testDataSet)

# 1.3 Build complete train dataset: original train dataset + train subject data set + train activity data set 

completeTrainDataSet <- cbind(subjectTrainDataSet, activityTrainDataSet, trainDataSet)

# 1.4 Actual merging

mergedDataSet <- rbind(completeTestDataSet, completeTrainDataSet)

# 2. Extract only the measurements on the mean and standard deviation for each measurement.

meanAndSTDFeatures <- grep("[Mm]ean|std", featuresDataSet$feature.name, value = T)
meanAndSTDDataSet <- cbind(mergedDataSet[1:2], mergedDataSet[meanAndSTDFeatures])

# 3. Use descriptive activity names to name the activities in the data set

finalDataSet <- merge(meanAndSTDDataSet, activityLabelsDataSet, by = "activity.id")

# 4. Appropriately label the data set with descriptive variable names.

# NOTE: Already done in the previous steps
# names(finalDataSet)
finalDataSet

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

averagedDataSet <- finalDataSet %>% 
    group_by(subject.id, activity.id, activity.name) %>% 
    summarize_at(meanAndSTDFeatures, mean) %>%
    as.data.frame()
averagedDataSet
write.table(averagedDataSet, file = "./data/step5-tidy-dataset.txt", sep = " ", row.names = F)

# dim(averagedDataSet) # Should have 180 observations (30 subjects X 6 activities), each with the respective mean