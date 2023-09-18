#Arahkan ke folder kerja
setwd("D:/SZN 5 pt.1/Praktikum Sains Data Geospasial Lanjut (SDGL)/Acara 4/SDGL4")

#Panggil library
library(raster)
library(caret)
library(Boruta)
library(rattle)
rasterOptions(progress = "text", tmpdir = paste0(getwd(), "/tmp"))

#Panggil R Data acara 03
load("D:/SZN 5 pt.1/Praktikum Sains Data Geospasial Lanjut (SDGL)/Acara 4/ac4/Acara 4 Full.RData")

#Pengaturan training model -- Pembahasan No 2
tr.ctrl <- trainControl(method = "repeatedcv", repeats = 10, number = 5,search = "random", verboseIter = T)

#Pembuatan model Decision tree dengan Variable Boruta
dt.boruta <- train(getConfirmedFormula(v.selection), data=train2, method="rpart", trControl = tr.ctrl)
fancyRpartPlot(dt.boruta$finalModel, main = "Hasil Decision Tree")

#Melihat akurasi nilai model decision tree dengan variable boruta 

dt.tune <- train(getConfirmedFormula(v.selection), data = train2, method = "rpart", metric = "Accuracy", 
                 tuneLength = 5, trControl = tr.ctrl)
dt.final <- train(getConfirmedFormula(v.selection), data = train2, method = "rpart", metric = "Accuracy", 
                  tuneGrid = dt.tune$bestTune, trControl = tr.ctrl)

#plot hasil tuning Random Forest dengan Boruta 
dt.tune
dt.final

#variable importance model decision tree dengan variable boruta 
varImp(dt.final)

#Pembuatan model decision tree untuk RFE dengan terlebih dahulu mengkonversi hasil RFE ke formula
result_rfe1$optVariables
rfe.formula <- paste(result_rfe1$optVariables, collapse="+")
rfe.formula <- paste("factor(LU)~", rfe.formula, sep = " ")
dt.rfe <- train(formula(rfe.formula), data=train2, method="rpart", trControl = tr.ctrl)
fancyRpartPlot(dt.rfe$finalModel, main = "Hasil Decision Tree RFE")

#Melihat akurasi nilai model decision tree dengan variable RFE
dt.tuneRFE <- train(formula(rfe.formula), data = train2, method = "rpart", metric = "Accuracy", tuneLength = 5, 
                    trControl = tr.ctrl)
dt.finalRFE <- train(formula(rfe.formula), data = train2, method = "rpart", metric = "Accuracy", tuneGrid = 
                       dt.tuneRFE$bestTune, trControl = tr.ctrl)
plot(dt.tuneRFE)
dt.tuneRFE
dt.finalRFE


#variable importance model decision tree dengan variable RFE 
varImp(dt.finalRFE)

#Setting training model untuk Random Forest
rf.tune <- train(getConfirmedFormula(v.selection), data = train2, method = "rf", metric = "Accuracy", 
                 tuneLength = 5, trControl = tr.ctrl)
rf.final <- train(getConfirmedFormula(v.selection), data = train2, method = "rf", metric = "Accuracy", 
                  tuneGrid = rf.tune$bestTune, trControl = tr.ctrl)

#plot hasil tuning Random Forest dengan Boruta 
plot(rf.tune)
rf.tune
rf.final

#variable importance Random Forest dengan Boruta 
varImp(rf.final)

#training untuk support vector machine DENGAN V.BORUTA
svm.tune <- train(getConfirmedFormula(v.selection), data = train2, method = "svmRadial", metric = 
                    "Accuracy", tuneLength = 5, trControl = tr.ctrl)
svm.final <- train(getConfirmedFormula(v.selection), data = train2, method = "svmRadial", metric = 
                     "Accuracy", tuneGrid = svm.tune$bestTune, trControl = tr.ctrl)

#plot hasil tuning SVM V.BORUTA
plot(svm.tune)
svm.tune
svm.final

#variable importance SVM V. BORUTA
varImp(svm.final)

# proses training rf dan svm untuk hasil RFE
rf.tuneRFE <- train(formula(rfe.formula), data = train2, method = "rf", metric = "Accuracy", tuneLength = 5, 
                    trControl = tr.ctrl)
rf.finalRFE <- train(formula(rfe.formula), data = train2, method = "rf", metric = "Accuracy", tuneGrid = 
                       rf.tuneRFE$bestTune, trControl = tr.ctrl)
svm.tuneRFE <- train(formula(rfe.formula), data = train2, method = "svmRadial", metric = "Accuracy", 
                     tuneLength = 5, trControl = tr.ctrl)
svm.finalRFE <- train(formula(rfe.formula), data = train2, method = "svmRadial", metric = "Accuracy", 
                      tuneGrid = svm.tuneRFE$bestTune, trControl = tr.ctrl)

#lakukan pengecekan variable importance dan plot Random forest UNTUK RFE
plot(rf.tuneRFE)
rf.tuneRFE
rf.finalRFE

varImp(rf.finalRFE) 

#INI SVM DENGAN RFE
plot(svm.tuneRFE)
svm.tuneRFE
svm.finalRFE

varImp(rf.finalRFE)

# perhitungan akurasi dengan menggunakan data test
dt.predict <- predict(dt.boruta, test2)
dt.predictRFE <- predict(dt.rfe, test2)
rf.predict <- predict(rf.final, test2)
svm.predict <- predict(svm.final, test2)
rf.predictRFE <- predict(rf.finalRFE, test2)
svm.predictRFE <- predict(svm.finalRFE, test2)

#hitung confusion matrix dt, svm dan rf
dt.confusion <- confusionMatrix(dt.predict, factor(test2$LU))
dt.confusion <- confusionMatrix(dt.predictRFE, factor(test2$LU))
rf.confusion <- confusionMatrix(rf.predict, factor(test2$LU))
svm.confusion <- confusionMatrix(svm.predict, factor(test2$LU))
rf.confusionRFE <- confusionMatrix(rf.predictRFE, factor(test2$LU))
svm.confusionRFE <- confusionMatrix(svm.predictRFE, factor(test2$LU))

#lakukan prediksi ke data raster 

setwd("D:/SZN 5 pt.1/Praktikum Sains Data Geospasial Lanjut (SDGL)/Acara 4/SDGL4/SIMPAN")
library(rgdal)
lst <- list.files(getwd(), "add2.tif")
crp <- raster("crop2.tif")
rst <- stack(lst)

rst <- rst * crp
nm <- names(train2)
nm <- nm[2:103]

#Mengganti nama layer raster
names(rst) <- c(nm)

# proses klasifikasi ke data raster
dt.class <- predict(rst, dt.boruta, progress = "text")
dt.classRFE <- predict(rst, dt.rfe, progress = "text")

dt.prob <- predict(rst, dt.final, progress = "text", type = "prob")
dt.probRFE <- predict(rst, dt.finalRFE, progress = "text", type = "prob")

rf.prob <- predict(rst, rf.final, progress = "text", type = "prob")
rf.class <- predict(rst, rf.final, progress = "text")

svm.prob <- predict(rst, svm.final, progress = "text", type = "prob")
svm.class <- predict(rst, svm.final, progress = "text")

rf.probRFE <- predict(rst, rf.finalRFE, progress = "text", type = "prob")
rf.classRFE <- predict(rst, rf.finalRFE, progress = "text")

svm.probRFE <- predict(rst, svm.finalRFE, progress = "text", type = "prob")
svm.classRFE <- predict(rst, svm.finalRFE, progress = "text")

#simpan data raster dan cek hasilnya pada QGIS atau ArcGIS

# CLASSIFICATION SVM PROB VARIABLE BORUTA
writeRaster(svm.prob, "svm_prob_boruta.tif", format = "GTiff", datatype = "FLT4S")

# CLASSIFICATION SVM VARIABLE BORUTA 
writeRaster(svm.class, "svm_class_boruta.tif", format = "GTiff", datatype = "INT1U")

# CLASSIFICATION RF PROB VARIABLE BORUTA
writeRaster(rf.prob, "rf_prob_boruta.tif", format = "GTiff", datatype = "FLT4S")

# CLASSIFICATION RF VARIABLE BORUTA 
writeRaster(rf.class, "rf_class_boruta.tif", format = "GTiff", datatype = "INT1U")

# CLASSIFICATION SVM PROB VARIABLE RFE
writeRaster(svm.probRFE, "svm_prob_rfe.tif", format = "GTiff", datatype = "FLT4S")

# CLASSIFICATION SVM VARIABLE RFE  
writeRaster(svm.classRFE, "svm_class_rfe.tif", format = "GTiff", datatype = "INT1U")

# CLASSIFICATION RF PROB VARIABLE RFE
writeRaster(rf.probRFE, "rf_prob_rfe.tif", format = "GTiff", datatype = "FLT4S")

# CLASSIFICATION RF VARIABLE RFE
writeRaster(rf.classRFE, "rf_class_rfe.tif", format = "GTiff", datatype = "INT1U")

# CLASSIFICATION DT VARIABLE BORUTA 
writeRaster(dt.class, "DT_class_rfe.tif", format = "GTiff", datatype = "INT1U")

# CLASSIFICATION DT PROB VARIABLE BORUTA
writeRaster(dt.prob, "dt_prob.tif", format = "GTiff", datatype = "FLT4S")
writeRaster(dt.probRFE, "rf_prob_rfe.tif", format = "GTiff", datatype = "FLT4S")

# CLASSIFICATION DT VARIABLE RFE 
writeRaster(dt.classRFE, "DT_class_iniRFE.tif", format = "GTiff", datatype = "INT1U")

