#
# Overfitter configuration for Boosted Linear Model
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
mlmethod <- 'bstLs'

# list of parameters
parameters <- list()
parameters[['mstop']] <- c(20, 50, 100, 400)
parameters[['nu']] <- c(0.01, 0.1, 0.2, 0.3, 0.7, 1.0)

# Wrapper for training a classifier
# @param p: current set of parameters
# @param trainingset: set to train model on
buildmodel <- function(p, trainingset) {
  tunegrid <- data.frame(mstop=p$mstop, nu=p$nu)
  trcontrol <- trainControl(method='none')
  classifier <- train(class ~., data=trainingset, 'bstLs', trControl=trcontrol, tuneGrid=tunegrid)
  return(classifier)
}

# Wrapper for predicting using trained model
# @param classifier: classifier to use to predict
# @param validset: set to validate results on
makeprediction <- function(classifier, validset) {
  predicted <- predict(classifier, newdata=validset, type='prob')$positive
  return(predicted)
}