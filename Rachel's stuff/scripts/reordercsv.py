'''
reorders a csv file with openpose data. The first row (under the columns) must be an arbitrary row in which the very last column is filled.
You must have the arbitrary column with data in the last column since the rows of open pose data is uneven
This script gets rid of knee data and also outputs a csv called _slash_3d_reordered_data.csv
python reordercsv.py (openpose file name). 
'''


import rosbag, sys, csv
import time
import string
import os #for file management make directory
import shutil #for file management, copy file
import pandas as pd
import numpy as np
import math

#verify correct input arguments: 1 or 2
if (len(sys.argv) > 2 or len(sys.argv) <= 1):
    print "invalid number of arguments:   " + str(len(sys.argv))
    print "should be 2: 'reordercsv.py' and 'csvName'"
    sys.exit(1)

openpose_csv = sys.argv[1]
openpose_df = pd.read_csv(openpose_csv)

#order: lwrist, rwrist, neck, nose, lelbow, relbow, lshoulder, rshoulder, lhip, rhip, leye, reye, lear, rear

reorder_df = openpose_df.copy()
reorder_df = reorder_df.rename(columns={"bodyparts": "lwrist.x", "-": "lwrist.y", "name": "lwrist.z",
        "x": "rwrist.x", "y": "rwrist.y", "z": "rwrist.z",
        "-.1" : "neck.x", "name.1": "neck.y", "x.1": "neck.z",
        "y.1" : "nose.x", "z.1": "nose.y", "-.2": "nose.z",
        "name.2": "lelbow.x", "x.2": "lelbow.y", "y.2": "lelbow.z",
        "z.2": "relbow.x", "Unnamed: 23": "relbow.y", "Unnamed: 24" : "relbow.z",
        "Unnamed: 25": "lshoulder.x", "Unnamed: 26": "lshoulder.y", "Unnamed: 27": "lshoulder.z",
        "Unnamed: 28": "rshoulder.x", "Unnamed: 29" : "rshoulder.y", "Unnamed: 30": "rshoulder.z",
        "Unnamed: 31": "lhip.x", "Unnamed: 32": "lhip.y", "Unnamed: 33": "lhip.z",
        "Unnamed: 34": "rhip.x", "Unnamed: 35": "rhip.y", "Unnamed: 36": "rhip.z",
        "Unnamed: 37": "leye.x", "Unnamed: 38": "leye.y", "Unnamed: 39": "leye.z",
        "Unnamed: 40": "reye.x", "Unnamed: 41": "reye.y", "Unnamed: 42": "reye.z",
        "Unnamed: 43": "lear.x", "Unnamed: 44": "lear.y", "Unnamed: 45": "lear.z",
        "Unnamed: 46": "rear.x", "Unnamed: 47": "rear.y", "Unnamed: 48": "rear.z"})

#Remove all unwanted columns
reorder_df = reorder_df.drop(reorder_df.columns[49:], axis=1)
#print(reorder_df.columns)
#dictionary for indexing
parts_dict = {'\"LWrist\"': 7, '\"RWrist\"': 10, '\"Neck\"': 13, '\"Nose\"': 16, '\"LElbow\"': 19, '\"RElbow\"' : 22, 
        '\"LShoulder\"' : 25, '\"RShoulder\"': 28, '\"LHip\"': 31, '\"RHip\"': 34, '\"LEye\"': 37, '\"REye\"': 40, '\"LEar\"': 43, '\"REar\"': 46}

#Remove first row & fill the dataframe with NaN where the column is a body part's coordinate
reorder_df = reorder_df.iloc[1:]
reorder_df.iloc[:, 7:] = np.nan

#print (openpose_df.iloc[:, 9])
#iterate through the open pose csv and fill the dataframe accordingly

rowNum = len(openpose_df)
colNum = len(openpose_df.columns)

for r in range(1,rowNum):
    for c in range(8,colNum,4):
        if(type(openpose_df.iloc[r,c]) is str):
            if(openpose_df.iloc[r,c] in parts_dict.keys()):
                i = parts_dict[openpose_df.iloc[r,c]]
                reorder_df.iloc[r-1,i] = openpose_df.iloc[r,c+1]
                reorder_df.iloc[r-1,i+1] = openpose_df.iloc[r,c+2]
                reorder_df.iloc[r-1,i+2] = openpose_df.iloc[r,c+3]
                #print(openpose_df.iloc[r,c])
                #print("i" + str(i))
                #print("row: " + str(r) + ", col: " + str(c))
                #print(str(reorder_df.iloc[r-1,i]) + " " + str(openpose_df.iloc[r,c+1]))
        else:
            break

#print(reorder_df["nose.x"])

reorder_df.to_csv("_slash_3d_reordered_data.csv", index=False)

print "Done"


