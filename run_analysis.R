#http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones


# install.packages("data.table)
library("data.table")
library('tidyverse')

# downloading raw data
if(!file.exists('./data')){dir.create('./data')}
fileUrl <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
download.file(fileUrl, destfile = './data/dataset.zip', method = 'curl')
unzip(zipfile = './data/dataset.zip', exdir = './data/')

folder <- './data/UCI HAR Dataset'


# cleaning activity labels
activityLabels <- fread("./data/UCI HAR Dataset/activity_labels.txt")
names(activityLabels) <- c('activityId','activity')

# cleaning feature labels
features <- fread("./data/UCI HAR Dataset/features.txt")
features <- features[,2]
names(features) <- 'featureNames'

#create vector of fields to keep
keepVect <- grep('mean|std',features$featureNames, ignore.case = TRUE, value = TRUE)


# loading train data sets
train_x<-read.table(paste0(folder,"/train/X_train.txt"))
names(train_x) <- features$featureNames

train_y<-read.table(paste0(folder,"/train/y_train.txt"))
names(train_y) <- 'activityId'

train_sub<-read.table(paste0(folder,"/train/subject_train.txt"))
names(train_sub) <- 'subjectId'

# merging all train data sets
train <- cbind(train_sub, train_y, train_x)


# loading test data sets
test_x<-read.table(paste0(folder,"/test/X_test.txt"))
names(test_x) <- features$featureNames

test_y<-read.table(paste0(folder,"/test/y_test.txt"))
names(test_y) <- 'activityId'

test_sub<-read.table(paste0(folder,"/test/subject_test.txt"))
names(test_sub) <- 'subjectId'

# merging all test data sets
test <- cbind(test_sub, test_y, test_x)


# joining train/test
data <- rbind(train,test)

# updating keepVect with labels
keepVect <- append(keepVect, c('subjectId','activityId'))

# keeping only mean/std fields
data <- data[,names(data) %in% keepVect]

# adding in activity description
data <- merge(data, activityLabels)
data <- data[,c(2,89,3:88)]




# Create a second, independent tidy data set with the average of each variable
# for each activity and each subject


tidyData <- data %>%
  group_by(subjectId, activity) %>%
  summarise_all(funs(mean))

write.table(tidyData, "tidyData.txt", row.name=FALSE)
