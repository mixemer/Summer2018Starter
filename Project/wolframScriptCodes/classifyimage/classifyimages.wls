#!/usr/bin/env wolframscript
(* ::Package:: *)

encodeID[expr_]:=StringReplace[Developer`EncodeBase64@BinarySerialize@expr,"/"->"~"]
decodeID[expr_]:=BinaryDeserialize@Developer`DecodeBase64ToByteArray@StringReplace[expr,"~"->"/"]


ClearAll[getFileNames,fromFileNameGetGeoRange]

getFileNames[folderName_] := 
	FileNames["*.png",FileNameJoin[{NotebookDirectory[],folderName}],Infinity];

fromFileNameGetGeoRange[fileName_] := 
	decodeID[FileBaseName@fileName]["GeoRange"];


ClearAll[associateFilesToGeoRange]
associateFilesToGeoRange[fileNames_] := 
	Map[
		File[#] -> fromFileNameGetGeoRange[#] &,
		getFileNames[fileNames]
	]


createClass[x_] := Which[x < 1.5, 1, x <= 2.5, 2, x <= 3.5, 3];


Print["data collecting..."]


ClearAll[training,validation]

training = associateFilesToGeoRange["training"];
validation = associateFilesToGeoRange["validation"];

Length[training]

trainingSmall = TakeSmallestBy[training,Last,UpTo[21280]];
validationSmall = TakeSmallestBy[validation,Last,UpTo[2971]];


Print["data collecting as classes..."]


ClearAll[trainingClassed,validationClassed]

trainingClassed = MapAt[createClass,trainingSmall,{All,2}];
validationClassed = MapAt[createClass,validationSmall,{All,2}];

Print[Length[trainingClassed]]
Print[Length[validationClassed]]


tnet = Import[File["/Users/mehmetsahin/Desktop/wolframscpt/classifyimage/tnet.wlnet"]];
(*File["~/wolframscpt/tnet.wlnet"]*)
tnetUninitilized = NeuralNetworks`NetDeinitialize[tnet];

ClearAll[choppedTNet]
choppedTNet = NetTake[tnetUninitilized,1];


ClearAll[finalLayers]

finalLayers = NetChain[{ConvolutionLayer[64,2,"Stride"->2,"Input"->{512,8,8}],Ramp,FlattenLayer[],LinearLayer[512],Ramp,LinearLayer[3],SoftmaxLayer[]},"Input"->{512,8,8},"Output"->NetDecoder[{"Class",{1,2,3}}]];


ClearAll[netJoined]
netJoined = NetJoin[choppedTNet,finalLayers];


dir="/Users/mehmetsahin/Desktop/wolframscpt/classifyimage/progress";
(*"~/classifyimage/progress"*)


Print["training starts..."]

ClearAll[netTrained]
netTrained = NetTrain[netJoined,trainingClassed,All,ValidationSet->validationClassed,TargetDevice->"CPU",MaxTrainingRounds->30,TrainingProgressCheckpointing->{"Directory",dir}];


(*Print["exporting..."]
Export["amazonTrainedNet3.wlnet",netTrained]*)
