# Peer-graded Assignment: Getting and Cleaning Data Course Project

The purpose of this project is to demonstrate how to properly collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis.  The used data represent data collected from the accelerometers from Samsung Galaxy S smartphones to study physical actions. A full description is available at the site where the data was obtained: [http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)

The complete code can be seen here: [https://github.com/rigalves/clean-data-assignment/blob/master/run_analysis.R](https://github.com/rigalves/clean-data-assignment/blob/master/run_analysis.R).

# Instructions
## run_analysis.R
Following the _reproducible research principle_ in data science, the actual data files are not included in this repository. Instead, the script downloads the rawest form of the files, in this case, a zip file. After that the file is unzipped and included in the "./data" folder.
## Dependencies
The only dependency is the [dplyr](https://cran.r-project.org/web/packages/dplyr/vignettes/dplyr.html) library. To install the library, execute the following code:
```{r }
install.packages("dplyr")
```
## Codebook
You can take a look [here](https://github.com/rigalves/clean-data-assignment/blob/master/CodeBook.md) to get more detail the resulting datasets variables.
# Objectives of the exercise 
The purpose of the script is to clean and summarize the source data files, to fulfill the following five objectives.
## 1. Merge the training and the test sets
The approach here is to generate a group of parial datasets, one for each involved file. One particular case is the activity labels dataset:
```{r }
activityLabelsDataSetPath <- paste(unzippedDataSetsPath, "activity_labels.txt", sep = "")
activityLabelsDataSet <- read.table(file = activityLabelsDataSetPath)
```
Once the data frames are ready, the names are setted, as following:
```{r }
names(activityLabelsDataSet) <- c("activity.id", "activity.name")
```
When setting the training and the test main dataset names, the features dataset is used for this purpose:
```{r }
names(testDataSet) <- featuresDataSet$feature.name
```
Finally, the complete datasets for test and training are created and merged:
```{r }
completeTestDataSet <- cbind(subjectTestDataSet, activityTestDataSet, testDataSet)
completeTrainDataSet <- cbind(subjectTrainDataSet, activityTrainDataSet, trainDataSet)
mergedDataSet <- rbind(completeTestDataSet, completeTrainDataSet)
```
## 2. Extract the mean and standard measurements
In this part, of all the measurement types (like max(), min(), among others) is required to only take the ones related with the standard deviation and the mean. To accomplish this, the column names are filtered using regular expressions and then rebuild the dataset:
```{r }
meanAndSTDFeatures <- grep("[Mm]ean|std", featuresDataSet$feature.name, value = T)
meanAndSTDDataSet <- cbind(mergedDataSet[1:2], mergedDataSet[meanAndSTDFeatures])
```
## 3. Name the activities
At this point, the activities are just IDs, so, it is necessary to use the activity labels data set and merge it with the current dataset:
```{r }
finalDataSet <- merge(meanAndSTDDataSet, activityLabelsDataSet, by = "activity.id")
```
## 4. Label the variables in a descriptible way
This has been taken care in the previous steps. Every columns has their own descriptive name, for example:
```{r }
head(names(finalDataSet))
[1] "activity.id"       "subject.id"        "tBodyAcc-mean()-X" "tBodyAcc-mean()-Y" "tBodyAcc-mean()-Z"
[6] "tBodyAcc-std()-X" 
```
In this step, the final dataset is ready, waiting to be summarized.
## 5. Averaged dataset
This is the last step and what is required here is create a second dataset with tidy data and needs to contain the average of each variable (all the feature calculations), for each 6 activities (walking, sitting, laying, ...) and each subject (all the 30 people that took part in the experiment)
```{r }
averagedDataSet <- finalDataSet %>% 
    group_by(subject.id, activity.id, activity.name) %>% 
    summarize_at(meanAndSTDFeatures, mean) %>%
    as.data.frame()
```
Finally, a text file is created with the resulting tidy data:
```{r }
write.table(averagedDataSet, file = "./data/step5-tidy-dataset.txt", sep = " ", row.names = F)
```
# Questions
If you have any, feel free to ask: [rigoberto.alvarez@gmail.com](rigoberto.alvarez@gmail.com)