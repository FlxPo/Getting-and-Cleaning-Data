dir = getwd()

#Loading test data
XTest = read.table(file.path(dir, "UCI HAR Dataset/test/X_test.txt"))
yTest = read.table(file.path(dir, "UCI HAR Dataset/test/y_test.txt"))
subjectTest = read.table(file.path(dir, "UCI HAR Dataset/test/subject_test.txt"))
#Loading train data                          
XTrain = read.table(file.path(dir, "UCI HAR Dataset/train/X_train.txt"))
yTrain = read.table(file.path(dir, "UCI HAR Dataset/train/y_train.txt"))
subjectTrain = read.table(file.path(dir, "UCI HAR Dataset/train/subject_train.txt"))

#Merging the two datasets
XMerged = rbind(XTrain, XTest)
yMerged = rbind(yTrain, yTest)
subjectMerged = rbind(subjectTrain, subjectTest)

#Naming columns of the single columns datasets
colnames(yMerged) = "activity"
colnames(subjectMerged) = "subject"

#Naming columns of the 561 column "X" dataset
features = read.table(file.path(dir, "UCI HAR Dataset/features.txt"))
colnames(XMerged) = features[,2]

#Transforming activities ids to activities names (1 -> WALKING)
activityLabels = read.table(file.path(dir, "UCI HAR Dataset/activity_labels.txt"))
yMergedLabelled = factor(as.numeric(yMerged[,1]))
levels(yMergedLabelled) = activityLabels[,2]
yMergedLabelled = as.data.frame(yMergedLabelled)
colnames(yMergedLabelled) = "activity"

#Subsetting "X" dataset to columns containing mean and std information
nameMatch = grep("mean|std", features[,2], value = T)
nameMatch = grep("meanfreq", nameMatch, value = T, invert = T, ignore.case = T)
nameMatch = gsub("\\(\\)", "", nameMatch)
nameMatch = gsub("\\-", ".", nameMatch)
XMeanStd = XMerged[,nameMatch]

#Merging "Subject", "X" and "y" datasets
finalDataset = cbind(subjectMerged, yMergedLabelled, XMeanStd)

#Function to get mean for each subject and for each subject of one variable
analyze = function(x, y) {
  d = tapply(x, y, mean)
  res = as.vector(t(d))
  res
}

#Using apply to loop through all variables of the dataset
y = list(finalDataset$subject, finalDataset$activity)
analysisResults = apply(finalDataset[,3:ncol(finalDataset)], 2, analyze, y)
colnames(analysisResults) = nameMatch

#Creating the first two columns of the dataset
subjectsId = rep(1:30, each = 6)
activitiesId = rep(1:6,30)

#Merging all data to create the tidy dataset and writing the result to a txt file
tidyDataset = cbind(subjectsId, activitiesId, analysisResults)
tidyDataset = as.data.frame(tidyDataset)
tidyDataset$activitiesId = factor(tidyDataset$activitiesId)
levels(tidyDataset$activitiesId) = activityLabels[,2]
write.table(tidyDataset, file = "UCI HAR data analysis.txt", row.names = F)
