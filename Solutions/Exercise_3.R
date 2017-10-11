####################################################################################
#################################### EXERCISE 1 #################################### 
####################################################################################
### PART A - Data Input ###
# A.2
auto <- read.table("https://archive.ics.uci.edu/ml/machine-learning-databases/auto-mpg/auto-mpg.data-original")

# A.3
names(auto) <- c("mpg", "cyl", "disp", "hp", "weight", "acc", "model.yr", "origin", "name")

# A.4
auto$cyl <- factor(auto$cyl)
auto$name <- as(auto$name, "character")

# A.5
head(auto)


### PART B - Missing Values ###
# B.1
missing <- which(is.na(auto), arr.ind = TRUE)
missing

# B.2
auto[missing[,1], ]


### PART C - Sorting ###
# C.1
sort.index <- order(auto$mpg, decreasing = TRUE, na.last = NA)
auto.sorted <- auto[sort.index, ]

# C.2
head(auto.sorted, 5)

# C.3
tail(auto.sorted, 5)


### PART D - String Manipulation ###
# D.1
diesel.index <- grep("diesel", auto$name)
diesel.index

# D.2 
auto$diesel <- 0
auto$diesel[diesel.index] <- 1

# D.3
auto$diesel <- factor(auto$diesel)

# D.4
str(auto)


####################################################################################
#################################### EXERCISE 2 #################################### 
####################################################################################
### PART A - Data Input ###
# A.2
summary(auto)

## B - create a histogram of the response variable (mpg)
hist(auto$mpg, col = "grey", main = "Histogram of MPG", xlab = "MPG")

## C - look at a boxplot of the response variable (mpg) grouped by number of cylinders
boxplot(mpg ~ cyl, data = auto, col = "grey",
        main = "Distribution of MPG by Number of Cylinders",
        xlab = "Cylinders", ylab = "MPG")

## D - create a scatterplot matrix including only mpg, cylinders, displacement, horsepower, 
##     weight, acceleration, and model year... what do you notice & what are the implications?
scatterplotMatrix(auto[,c("mpg", "cyl", "disp", "hp", "weight", "acc", "model.yr")])


####################################################################################
#################################### EXERCISE 3 #################################### 
####################################################################################
## A - regress mpg on horsepower & look at the summary & diagnostic plot... do you 
##     think that this model adequately fits the data?
modelA <- lm(mpg ~ hp, data=auto)
summary(modelA)
par(mfrow=c(2,2)); plot(modelA)

## B - fit a quadratic model with horsepower repeating what you did in Part A... does
##     this model fit the data better than the model in Part A? which do you prefer?
##     a plot may help here! or anova()
modelB <- lm(mpg ~ hp + I(hp^2), data=auto)
summary(modelB)
par(mfrow=c(2,2)); plot(modelB)
par(mfrow=c(1,1)); plot(auto$hp, auto$mpg, pch=20, xlab="Horsepower", ylab="MPG")
abline(reg = modelA, col="red", lwd=2)
curve(predict(modelB, data.frame(hp=x)), add=TRUE, col="green", lwd=2)

anova(modelA, modelB)

## C - fit the best possible model for the Auto MPG data... may be an iterative process
modelC1 <- lm(mpg ~ weight + model.yr, data=auto)
summary(modelC1)
par(mfrow=c(2,2)); plot(modelC1)
auto[c(330, 334, 333), ]  # look at potential outliers... top 3 mpg values
auto[52, c("mpg", "weight", "model.yr")]  # look at leverage point... heaviest vehicle

modelC2 <- lm(mpg ~ weight + I(weight^2) + model.yr, data=auto)
summary(modelC2)
par(mfrow=c(2,2)); plot(modelC2)
auto[c(330, 334, 396), c("mpg", "weight", "model.yr")]  # look at potential outliers... top 3 mpg values

anova(modelC1, modelC2)

finalModel <- lm(mpg ~ weight + I(weight^2) + model.yr + diesel, data=auto)
summary(finalModel)
par(mfrow=c(2,2)); plot(finalModel)
auto[c(330, 403, 119), ]  # look at potential outliers...
par(mfrow=c(1,1)); plot(auto$weight, auto$mpg, pch=20, xlab="Weight (lbs)", ylab="MPG", col=auto$diesel)

anova(modelC2, finalModel)

## D - using your model in Part C, predict the MPG for the 8 observations with missing MPG
missing.mpg <- auto[is.na(auto$mpg), ]
cbind(missing.mpg, fit=predict(finalModel, newdata = missing.mpg))

## E - contrasts... (1) 2500 vs 3000 lbs for same model year & engine type
##                  (2) 1980 vs 1970 for same weight & engine type
linContr <- function(model, contr){
  beta.hat <- model$coef
  cov.beta <- vcov(model)
  est <- contr %*% beta.hat
  se.est <- sqrt(contr %*% cov.beta %*% t(contr))
  ci95.lo <- est - qnorm(0.975)*se.est
  ci95.hi <- est + qnorm(0.975)*se.est
  out <- data.frame(est, se.est, ci95.lo, ci95.hi)
  round(out, 3)
}

linContr(finalModel, matrix(c(0, -500, -500^2, 0, 0), nrow=1, ncol=5))  # 2500 - 3000
linContr(finalModel, matrix(c(0, 0, 0, 10, 0), nrow=1, ncol=5))  # 1980 - 1970

