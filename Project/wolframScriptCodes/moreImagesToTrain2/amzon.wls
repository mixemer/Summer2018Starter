#!/usr/bin/env wolframscript
(* ::Package:: *)

Print["Starting Script."]

encodeID[expr_]:=StringReplace[Developer`EncodeBase64@BinarySerialize@expr,"/"->"~"]
decodeID[expr_]:=BinaryDeserialize@Developer`DecodeBase64ToByteArray@StringReplace[expr,"~"->"/"]



ClearAll[getFileNames,fromFileNameGetGeoRange]

getFileNames[folderName_] := 
	FileNames["*.png","~/moreImagesToTrain/"<>folderName,Infinity];
	(*FileNames["*.png",FileNameJoin[{NotebookDirectory[],folderName}],Infinity];*)

fromFileNameGetGeoRange[fileName_] := 
	decodeID[FileBaseName@fileName]["GeoRange"];


ClearAll[associateFilesToGeoRange]
associateFilesToGeoRange[fileNames_] := 
	Map[
		File[#] -> fromFileNameGetGeoRange[#] &,
		getFileNames[fileNames]
	]


ClearAll[training,validation]
Print["get data."]

training = associateFilesToGeoRange["training"];
validation = associateFilesToGeoRange["validation"];

Print[training//Length]
Print[validation//Length]


dir="~/moreImagesToTrain/progress"


ClearAll[tnet]
tnet = Import["/Users/mehmetsahin/Desktop/wolframscpt/moreImagesToTrain/amazonTrainedNet.wlnet"];
(*File["~/moreImagesToTrain/amazonTrainedNet.wlnet"]*)


Print["training starts..."]

ClearAll[netTrained]

netTrained = NetTrain[tnet,training,All,ValidationSet->validation,TargetDevice->"GPU",
TrainingProgressCheckpointing->{"Directory",dir}
];



Print["exporting..."]
Export["amazonTrainedNet2.wlnet",netTrained]

