#!/usr/bin/env wolframscript
(* ::Package:: *)

encodeID[expr_]:=StringReplace[Developer`EncodeBase64@BinarySerialize@expr,"/"->"~"]
decodeID[expr_]:=BinaryDeserialize@Developer`DecodeBase64ToByteArray@StringReplace[expr,"~"->"/"]
fromFileNameGetGeoRange[fileName_] := 
	ToExpression@First@StringSplit[decodeID[FileBaseName@fileName],"-"];


ClearAll[getFileNames]
getFileNames[folderName_] := 
	FileNames["*.png",FileNameJoin[{"/Users/mehmetsahin/Desktop/GitHubWL/Summer2018Starter/Project","StalliteImages",folderName}],Infinity];


ClearAll[associateFilesToGeoRange]
associateFilesToGeoRange[fileNames_List] := 
	Map[
		File[#] -> fromFileNameGetGeoRange[#] &,
		fileNames
	]


binaryWrite[expr_]:=binaryWrite[expr,CreateFile[]];
binaryWrite[expr_,file_]:=With[{bytes=BinaryWrite[file,BinarySerialize[expr]]},Close[file];
bytes];
binaryRead[file_]:=BinaryDeserialize[ReadByteArray[file]];


(* ::Input:: *)
(*trainData = RandomSample@associateFilesToGeoRange[getFileNames["Training"]];*)
(*validationData = RandomSample@associateFilesToGeoRange[getFileNames["Validation"]];*)


(* ::Input:: *)
(*tnet = Import[File["/Users/mehmetsahin/Downloads/2017-12-27T18-42-44_0_0123_05898_3.71e-3_9.47e-2.wlnet"]];*)


(* ::Input:: *)
(*choppedTNet = NetTake[tnet,1]*)


(* ::Input:: *)
(*finalLayers =NetChain[{PoolingLayer[8,"Function"->Mean],FlattenLayer[],LinearLayer[8000],ElementwiseLayer[Abs],LinearLayer[1000],ElementwiseLayer[Ramp],LinearLayer[1],ElementwiseLayer[Abs]},"Output"->"Scalar"];*)


(* ::Input:: *)
(*netJoin = NetJoin[choppedTNet,finalLayers];*)


(* ::Input:: *)
(*newTrainedNet = NetTrain[netJoin,trainData,ValidationSet->validationData];*)


(* ::Input:: *)
(*Export[FileNameJoin[{"/Users/mehmetsahin/Desktop/GitHubWL/Summer2018Starter/Project/NeuralNets","amazonTrainedNet.wlnet"}],newTrainedNet];*)
