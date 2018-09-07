# BOLD5000
BOLD5000: Brain, Object, Landscape Dataset <br>
Authors: Nadine Chang, John Pyles, Abhinav Gupta, Michael Tarr, Elissa Aminoff <br>
Paper is available on [arXiv](https://arxiv.org/abs/1809.01281)

![Alt text](relative/path/to/img.jpg?raw=true "Sample Images")

BOLD5000 is a large-scale, slow-event related fMRI dataset collected on 4 subjects, each observing 5,254 images over 15 scanning sessions. Our images are selected from three computer vision datasets.

1) 1,000 images from Scene Images (with scene categories based on SUN categories)
2) 2,000 images from the COCO dataset
3) 1,916 images from the ImageNet dataset

Please visit our website http://BOLD5000.org for more details and news & releases.

This repository contains our scanning scripts used to collect our fMRI data. It is able to replicate our collection process.
Note that we ask our subjects to perform a valence task, asking whether they 'like', 'neutral', 'dislike' the image shown. The user response is shown on console and saved to output file. 

## Script Instructions for Replication
To replicate our collection: 

1) Make sure to download our 'all_imgs.mat' file [here](https://www.dropbox.com/s/c4zbu1454iuo719/all_imgs.mat?dl=1) and have the file in the same directory as 'all_img_names.mat' and 'ScenesEventRelated.m'. It contains all the images used for presentation.
2) Run ScenesEventRelated.m
3) Fill out subject, session, run, and whether at scanning or not. 
   Ex: Subject ID = 1, Session = 1, Run = 1, At scanner = 1 (for scanning, or 0 for testing)
4) Run will start and continue until end of trials and run.
5) All run outputs including session #, run #, trial #, image name, time when stimulus was shown and removed, user response, etc... are all collected and saved in output file. An example has been provided for you under Subject_Data folder.


