require(xgboost)
require(methods)

train = read.csv('Data/train.csv',header=TRUE,stringsAsFactors = F)
test = read.csv('Data/test.csv',header=TRUE,stringsAsFactors = F)
train = train[,-1]
test = test[,-1]

y = train[,ncol(train)]
y = gsub('Class_','',y)
y = as.integer(y)-1 #xgboost take features in [0,numOfClass)

x = rbind(train[,-ncol(train)],test)
x = as.matrix(x)
x = matrix(as.numeric(x),nrow(x),ncol(x))
trind = 1:length(y)
teind = (nrow(train)+1):nrow(x)

# Set necessary parameter
param <- list("objective" = "multi:softprob",
              "eval_metric" = "mlogloss",
              "num_class" = 9,
              "nthread" = 8,
              'max_depth' = 10,
              "min_child_weight" = 4,
              "gamma" = 1,
              "subsample" = .9,
              "colsample_bytree" = .8)

#shuffle
trind <- trind[sample(nrow(trind)),]

# Run Cross Valication
cv.nround = 200
bst.cv = xgb.cv(param=param, data = x[trind,], label = y,
                nfold = 3, nrounds=cv.nround)

#shuffle
trind <- trind[sample(nrow(trind)),]

# Train the model
nround = 200
bst = xgboost(param=param, data = x[trind,], label = y, nrounds=nround)

# Make prediction
pred = predict(bst,x[teind,])
pred = matrix(pred,9,length(pred)/9)
pred = t(pred)

# Output submission
pred = format(pred, digits=2,scientific=F) # shrink the size of submission
pred = data.frame(1:nrow(pred),pred)
names(pred) = c('id', paste0('Class_',1:9))
write.csv(pred,file='Output/xgboost_6.csv', quote=FALSE,row.names=FALSE)
