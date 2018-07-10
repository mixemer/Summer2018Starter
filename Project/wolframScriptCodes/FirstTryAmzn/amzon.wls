#!/usr/bin/env wolframscript
(* ::Package:: *)

Print["Starting Script."]
encodeID[expr_]:=StringReplace[Developer`EncodeBase64@BinarySerialize@expr,"/"->"~"]
decodeID[expr_]:=BinaryDeserialize@Developer`DecodeBase64ToByteArray@StringReplace[expr,"~"->"/"]
ClearAll[getFileNames,fromFileNameGetGeoRange]

getFileNames[folderName_] := 
	FileNames["*.png","~/wolframscpt/"<>folderName,Infinity];
Print["Fuck"]

fromFileNameGetGeoRange[fileName_] := 
	decodeID[FileBaseName@fileName]["GeoRange"];
ClearAll[associateFilesToGeoRange]
associateFilesToGeoRange[fileNames_] := 
	Map[
		File[#] -> fromFileNameGetGeoRange[#] &,
		getFileNames[fileNames]
	]
ClearAll[training,validation,testing]
Print["get data."]
training = associateFilesToGeoRange["training"];
validation = associateFilesToGeoRange["validation"];
testing = associateFilesToGeoRange["testing"];

Print[training//Length]
Print[validation//Length]

ClearAll[trainSmall,validationSmall,testSmall]

trainSmall = RandomSample[TakeSmallestBy[training,Last,UpTo[11854]]];
validationSmall = RandomSample[TakeSmallestBy[validation,Last,UpTo[1975]]];
testSmall = RandomSample[TakeSmallestBy[testing,Last,UpTo[990]]];
ClearAll[tnet]
tnet = Import[File["~/wolframscpt/tnet.wlnet"]];
tnetUninitilized = NeuralNetworks`NetDeinitialize[tnet];
ClearAll[choppedTNet]
choppedTNet = NetTake[tnetUninitilized,1];
ClearAll[finalLayers]

Print["training starts..."]

finalLayers = NetChain[{ConvolutionLayer[64,2,"Stride"->2,"Input"->{512,8,8}],Ramp,FlattenLayer[],LinearLayer[512],Ramp,LinearLayer[1],Abs},"Input"->{512,8,8},"Output"->"Scalar"];
"training starts..."
ClearAll[netJoined]
netJoined = NetJoin[choppedTNet,finalLayers];
ClearAll[netTrained]
netTrained = NetTrain[netJoined,trainSmall,ValidationSet->validationSmall,TargetDevice->"GPU",MaxTrainingRounds->50];
Print["exporting..."]
Export["amazonTrainedNet.wlnet",netTrained]

