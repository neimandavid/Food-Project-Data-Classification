Put SaveModel, UseModel, plotGaussian, and your CSVs in the same folder

Name the CSVs E{something}.csv
In SaveModel, v is a vector of all those {something}s for the file you want to use to build the model

SaveModel spits out a bunch of plots; the second one is the state space plot, which is usually the most helpful. SaveModel should also create a folder containing a .mat file with the model and the state space plot.

UseModel applies a model to a single file. Change modeltouse and filetoread accordingly. UseModel should create a bunch of plots, plus a CSV with the segmentation data, and store them in the relevant folder in SaveModel.