# load the dplyr library from which grou_by and summarize_at functions will be 
# used later
library(dplyr)

# download the zip file from the given link
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
filename <- "getdata_dataset.zip"
# save it as 'getdata_dataset.zip' in your working directory
if (!file.exists(filename)){
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
        download.file(url, filename)
}

#unzipping the dataset and setting the working directory to UCI HAR Dataset
if (!file.exists("./UCI HAR Dataset")) { 
        unzip(filename) 
}

setwd("./UCI HAR Dataset")

# reading the activity labels and features file
# converting the second column from factor to character in order to use as 
# values and columnames later
labels <- read.table("activity_labels.txt")
features <- read.table("features.txt")
labels[,2] <- as.character(labels[,2])
features[,2] <- as.character(features[,2])

# reading the train and test data sets along with the labels and subjects and
# combining them respectively
train <- read.table("./train/X_train.txt")
train_labels <- read.table("./train/y_train.txt")
train_subjects <- read.table("./train/subject_train.txt")
train <- cbind(train_subjects, train_labels, train)

test <- read.table("./test/X_test.txt")
test_labels <- read.table("./test/y_test.txt")
test_subjects <- read.table("./test/subject_test.txt")
test <- cbind(test_subjects, test_labels, test)

# renaming the columna names for both train and test datasets
names(train) <- c("subject", "activity", features[,2])
names(test) <- c("subject", "activity", features[,2])

# merging the 2 datasets
merged_data <- rbind(train, test)

# converting the activity and subject columns to factor class
merged_data$activity <- factor(merged_data$activity, levels = labels[,1], 
                               labels = labels[,2])
merged_data$subject <- as.factor(merged_data$subject)

# extracting names of columns having mean and std in them along with the subject
# and activity columns
wanted_columns <- grep("mean\\(|std\\(", names(merged_data), ignore.case = TRUE)
wanted_columns <- c(1, 2, wanted_columns)
final_data <- merged_data[,wanted_columns]

# grouping the final data on subject and activity
final_data <- group_by(final_data, subject, activity)

# creating a second tidy data set having the average of each variable on the 
# grouped final data
# the below line summarizes the data taking the mean for every column using the
# names function except the first two columns of subject and activity
tidy_data <- summarize_at(final_data, c(names(final_data[, -(1:2)])), mean)

# writing the tidy data into a table
write.table(tidy_data, "tidy_data.txt", row.names = FALSE, quote = FALSE)

# printing the final result
tidy_data