#
# Overfitter configuration for Regularized Random Forest (RRF)
#

# packages to use during learning (loaded into each cluster node)
packages=c('pROC', 'caret')

library('foreach')
library('doParallel')
library('parallel')
source('../functions.r')
for (pkg in packages) {
  library(pkg, character.only=T)
}

# name of the learning method
mlmethod <- 'multinom'

# list of parameters
parameters <- list()
parameters[['maxit']] <- c(100, 300, 500)
parameters[['decay']] <- c(0.001, 0.1, 1, 10, 1000)

# Wrapper for training a classifier
# @param p: current set of parameters
# @param trainingset: set to train model on
buildmodel <- function(p, trainingset) {
  tunegrid <- data.frame(decay=p$decay)
  trcontrol <- trainControl(method='none')
  classifier <- train(class ~., data=trainingset, 'multinom', trControl=trcontrol, tuneGrid=tunegrid,
                      maxit=p$maxit, MaxNWts=10000)
  return(classifier)
}

# Wrapper for predicting using trained model
# @param classifier: classifier to use to predict
# @param validset: set to validate results on
makeprediction <- function(classifier, validset) {
  predicted <- predict(classifier, newdata=validset, type='prob')$positive
  return(predicted)
}