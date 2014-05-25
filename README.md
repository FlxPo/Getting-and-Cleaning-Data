Getting and Cleaning Data Course Project
=========================

This file documents the process used to build the dataset contained in the file "UCI HAR data analysis.txt", the following lines explaining the functionning of the R script used :

#Getting and cleaning data
##Loading the data in R
This first part of the script loads the explanatory variables (noted x), the corresponding activities (noted y), and the corresponding subject numbers, for both training and test phases of the analysis.

<pre><code>
dir = getwd()
XTest = read.table(file.path(dir, "UCI HAR Dataset/test/X_test.txt"))
yTest = read.table(file.path(dir, "UCI HAR Dataset/test/y_test.txt"))
subjectTest = read.table(file.path(dir, "UCI HAR Dataset/test/subject_test.txt"))
XTrain = read.table(file.path(dir, "UCI HAR Dataset/train/X_train.txt"))
yTrain = read.table(file.path(dir, "UCI HAR Dataset/train/y_train.txt"))
subjectTrain = read.table(file.path(dir, "UCI HAR Dataset/train/subject_train.txt"))
</pre></code>

##Merging the train and test datasets
We then merge the train and test datasets by using rbind :

<pre><code>
XMerged = rbind(XTrain, XTest)
yMerged = rbind(yTrain, yTest)
subjectMerged = rbind(subjectTrain, subjectTest)
</pre></code>

##Labelling columns 
All variables in the dataset are then explicitly named :

<pre><code>
colnames(yMerged) = "activity"
colnames(subjectMerged) = "subject"
features = read.table(file.path(dir, "UCI HAR Dataset/features.txt"))
colnames(XMerged) = features[,2]
</pre></code>

##Transforming activities ids to activities names (1 -> WALKING)
activityLabels = read.table(file.path(dir, "UCI HAR Dataset/activity_labels.txt"))
yMergedLabelled = factor(as.numeric(yMerged[,1]))
levels(yMergedLabelled) = activityLabels[,2]
yMergedLabelled = as.data.frame(yMergedLabelled)
colnames(yMergedLabelled) = "activity"

##Mean and Standard Deviation selection
We prepare the selection of mean and standard deviation explanatory variables by filtering the features vector using a regex. We also change the names to avoid problems when manipulating variable names (ie "()" or "-" characters).

<pre><code>
nameMatch = grep("mean|std", features[,2], value = T)
nameMatch = grep("meanfreq", nameMatch, value = T, invert = T, ignore.case = T)
nameMatch = gsub("\\(\\)", "", nameMatch)
nameMatch = gsub("\\-", ".", nameMatch)
XMeanStd = XMerged[,nameMatch]
</pre></code>

We can then merge all produced datasets into a properly labelled and cleaned dataset, before analysis :

<pre><code>
finalDataset = cbind(subjectMerged, yMergedLabelled, XMeanStd)
</pre></code>

#Analyzing data
We design here a function to get mean for each subject and for each subject of one variable. This function is subsequently called using apply to loop through all variables of the dataset, to produce the result : a dataset containing the average of each explanatory variable, for each subject and each activity.

<pre><code>
analyze = function(x, y) {
  d = tapply(x, y, mean)
  res = as.vector(t(d))
  res
}

y = list(finalDataset$subject, finalDataset$activity)
analysisResults = apply(finalDataset[,3:ncol(finalDataset)], 2, analyze, y)
colnames(analysisResults) = nameMatch

subjectsId = rep(1:30, each = 6)
activitiesId = rep(1:6,30)
</pre></code>

We finally merge all previously produced data to create the tidy dataset, translate it to a dataframe to relabel the activity names, and we write the result to a txt file :

<pre><code>
tidyDataset = cbind(subjectsId, activitiesId, analysisResults)
tidyDataset = as.data.frame(tidyDataset)
tidyDataset$activitiesId = factor(tidyDataset$activitiesId)
levels(tidyDataset$activitiesId) = activityLabels[,2]
write.table(tidyDataset, file = "UCI HAR data analysis.txt", row.names = F)
</pre></code>
