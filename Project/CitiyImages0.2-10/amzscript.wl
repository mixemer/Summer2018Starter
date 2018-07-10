(* ::Package:: *)

(* ::Section:: *)
(*Functions*)


Print["Starting Script."]


encodeID[expr_]:=StringReplace[Developer`EncodeBase64@BinarySerialize@expr,"/"->"~"]
decodeID[expr_]:=BinaryDeserialize@Developer`DecodeBase64ToByteArray@StringReplace[expr,"~"->"/"]


ClearAll[getFileNames,fromFileNameGetGeoRange]

getFileNames[folderName_] := 
	FileNames["*.png",FileNameJoin[{"/Users/mehmetsahin/Desktop/GitHubWL/Summer2018Starter/Project/CitiyImages0.2-10",folderName}],Infinity];

fromFileNameGetGeoRange[fileName_] := 
	decodeID[FileBaseName@fileName]["GeoRange"];


ClearAll[associateFilesToGeoRange]
associateFilesToGeoRange[fileNames_] := 
	Map[
		File[#] -> fromFileNameGetGeoRange[#] &,
		getFileNames[fileNames]
	]


(* ::Subsection:: *)
(*Import data as files:*)


ClearAll[training,validation,testing]

Print["Importing data as files."]
training = associateFilesToGeoRange["training"];
validation = associateFilesToGeoRange["validation"];
testing = associateFilesToGeoRange["testing"];


(* ::Input:: *)
(**)


(* ::Subsection:: *)
(*Take data from 0.2 to 4: *)


ClearAll[trainSmall,validationSmall,testSmall]

trainSmall = RandomSample[TakeSmallestBy[training,Last,UpTo[11854]]];
validationSmall = RandomSample[TakeSmallestBy[validation,Last,UpTo[1975]]];
testSmall = RandomSample[TakeSmallestBy[testing,Last,UpTo[990]]];

trainSmall[[All,2]]//MinMax
validationSmall[[All,2]]//MinMax
testSmall[[All,2]]//MinMax


(* ::Section:: *)
(*Neural net initilization*)


ClearAll[tnet,choppedTNet,finalLayers]

Print["Neural nets are initializing"]

tnet = Import[File["/Users/mehmetsahin/Downloads/2017-12-27T18-42-44_0_0123_05898_3.71e-3_9.47e-2.wlnet"]];
tnetUninitilized = NeuralNetworks`NetDeinitialize[tnet];
choppedTNet = NetTake[tnetUninitilized,1];

finalLayers = NetChain[{ConvolutionLayer[64,2,"Stride"->2,"Input"->{512,8,8}],Ramp,FlattenLayer[],LinearLayer[512],Ramp,LinearLayer[1],Abs},"Input"->{512,8,8},"Output"->"Scalar"]
netJoined = NetJoin[choppedTNet,finalLayers]

netTrained = NetTrain[netJoined,trainSmall,ValidationSet->validationSmall]


(* ::Subsection:: *)
(*Export the net:*)


Print["Exporting net on computer"]
Export[FileNameJoin[{"/Users/mehmetsahin/Desktop/GitHubWL/Summer2018Starter/Project/CitiyImages0.2-10","amazonTrainedNet.wlnet"}],netTrained]
