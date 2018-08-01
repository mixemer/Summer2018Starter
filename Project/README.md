![enter image description here][1]

# Introduction
Many interesting projects have been done with satellite images using Neural Networks such as semantic image segmentation for finding roads and homes, and more. In this project, we are taking a similar and broader look on satellite images by using a 50-layer convolution neural network (CNN) to predict the scale of satellite images.

# Getting started
When doing a project with neural networks, the first thing comes to one's mind is almost always the data, because data is one of the most important parts of the neural network. After failing to find the right data set for the project on the internet, I generated the data set (satellite images) in Wolfram Language using GeoImage. Firstly, I decided that I will only focus on one country (the United States) with satellite images that are scaled between 0.2 to 1200 Miles. 

    geoPositionOfCountry[entities_,numberOfPosition_Integer,folderName_String] :=
    	Module[
    		{countries, mesh},
    		countries = entities;
    		mesh = DiscretizeGraphics@EntityValue[countries,"Polygon"];
    		SeedRandom[Hash@{folderName,countries,RandomReal[{1,5}]}];
    		Reverse[RandomPoint[mesh,numberOfPosition],{2}]
    	]
    geoPositionOfCountry[{Entity["Country","UnitedStates"]},500,"training"]

Random GeoPosition in the United States:

![enter image description here][2]

Trying this data set on a pre-trained convolution neural network (CNN) by doing transfer learning in Machine learning, did not give a good result, the mean absolute error was 5.8 which was more than 500%. Finding out this made me question the way my data set was set up. The pre-trained convolution neural network I had was trained on only smaller scaled city images for image segmentation. That could be the reason I am not getting any promising result. I then decided to decrease the scale of the satellite images to between 0.2 to 4 Miles instead of having 0.2 to 1200 Miles and focus on only three cities (Dallas, Chicago, and Houston) in the United States

    geoPositionOfCity[{Entity[
       "City", {"Dallas", "Texas", "UnitedStates"}], 
      Entity["City", {"Chicago", "Illinois", "UnitedStates"}], 
      Entity["City", {"Houston", "Texas", 
        "UnitedStates"}]}, 700, "training"]
![enter image description here][3]

Then, I uninitialized the pre-trained net model and retrain it with 11854 training, 1975 validation and 990 testing images on Amazon EC2 GPU which took 8 hours to complete. 

The convolution neural network (CNN) I obtained from a paper (can be found in the summary section) was chopped and added needed layers for the project:

![enter image description here][4]

Before we go further, I also want to mention that the scale distribution of satellite images is exponential, meaning that there is more image close to earth than above. For instance, we have more images that are close 0.2 GeoRange than 4 Miles. The reason I chose this way of setting data so CNN can predict smaller scaled images better.

![enter image description here][5]

After the training with the above CNN, I got 29% mean absolute error. The error was better than what I had before. However, It was still bad to predict the scale of satellite images. To decrease the error percentage, I added more data, 9814 training, and 1050 validation to train it on top what I had before, and tested it with 420 images. The new error rate was 20% which indicated that with more data and more time, the CNN can learn and predict better.

Some of the prediction from 20% mean absolute error CNN: 

    encodeID[expr_]:=StringReplace[Developer`EncodeBase64@BinarySerialize@expr,"/"->"~"];
    decodeID[expr_]:=BinaryDeserialize@Developer`DecodeBase64ToByteArray@StringReplace[expr,"~"->"/"];

    getFileNames[folderName_] := 
    	FileNames["*.png",FileNameJoin[{NotebookDirectory[],folderName}],Infinity];
    
    fromFileNameGetGeoRange[fileName_] := 
    	decodeID[FileBaseName@fileName]["GeoRange"];

    associateFilesToGeoRange[fileNames_] := 
    	Map[
    		File[#] -> fromFileNameGetGeoRange[#] &,
    		getFileNames[fileNames]
    	]

    testing2 = RandomSample@associateFilesToGeoRange["testing"];

    sortPerformance[net_,data_] := 
    	With[
    		{img = Map[Import,data[[All,1]]], correspondingScale = data[[All,2]]},
    		SortBy[
    			AssociationThread[img,Transpose[{net[img],correspondingScale}]],
    			Abs[First[#] - Last[#]]&
    		]
    	]

    dataset2 = sortPerformance[tnet2, testing2];
    Normal@dataset2[[10 ;; 12]]
    Normal@dataset2[[-2 ;;]]

![enter image description here][6]

Now, I was wondering to see how the CNN would behave with bigger scale satellite images. I know that in the first attempt with a bigger scale (0.2 to 1200 Miles) It failed, but that time the images were from all of the United States. So, I generated a new dataset ranged from 1.3 to 10 Miles that were only in city images from Dallas, Chicago, and Houston. This time training took 4 hours with 11494 training and 1050 validation. After testing the CNN with 420 testing images, I got a really low mean absolute error rate of 0.08 which meant that the CNN could predict the scale of satellite images by up to 92% correctly. This was a success.

# Summary

In this project, we discovered that a convolution neural network (CNN) might fail to predict satellite images that have really big scales. However, when scales are decreased and satellite images are focused on cities CNN can predict better. 

The convolution neural network (CNN) that was used in this project can be found here: http://community.wolfram.com/groups/-/m/t/1250199

### Note: Even though CNN works well, it can still make bad predictions (some really bad). I believe that if we train the CNN with more data for more hours, the bad predictions will start decrease. I also believe that it is almost impossible to predict the scale of satellite images with 100% accuracy because there are too many examples of satellite images and Earth can be really fractal such as mountains and rivers. 

  [1]: http://community.wolfram.com//c/portal/getImageAttachment?filename=ScreenShot2018-07-11at3.02.32PM.png&userId=1363688
  [2]: http://community.wolfram.com//c/portal/getImageAttachment?filename=1.png&userId=1363688
  [3]: http://community.wolfram.com//c/portal/getImageAttachment?filename=2.png&userId=1363688
  [4]: http://community.wolfram.com//c/portal/getImageAttachment?filename=3.png&userId=1363688
  [5]: http://community.wolfram.com//c/portal/getImageAttachment?filename=ScreenShot2018-07-11at4.15.57PM.png&userId=1363688
  [6]: http://community.wolfram.com//c/portal/getImageAttachment?filename=ScreenShot2018-07-11at3.54.02PM.png&userId=1363688
