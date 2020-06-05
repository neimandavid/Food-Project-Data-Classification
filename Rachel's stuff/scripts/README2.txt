Libraries to import:

pandas
numpy
hmmlearn.hmm
from scipy.optimize import least_squares
pickle
plotly
matplotlib
cv2
pil
Tkinter
sys

(There may be others that I don't know of, or these might not be valid libraries. Some of these libraries you might not need.
If you try to run the file, and it doesn't work, then just import the libraries it tells you to import.)

To use visualizer.py, you must have an imu_data file. (Just use the ones I've provided since that has the column names needed).

The visualizer script also requires a video. In order to produce a video from your bag file, you can use the following commands in preferably, an empty folder:

rosrun image_view extract_images _sec_per_frame:=0.01 image:=/camera/color/image_raw/
rosbag play [BAG_FILE_NAME]

You can use rosbag info (name) to check if you got the right number of frames, and if this doesn't work, you can try running the launch file in the image_view directory of ros.
Instructions for the launch file are here: http://wiki.ros.org/rosbag/Tutorials/Exporting%20image%20and%20video%20data

if the fps is 15 use:
mencoder "mf://*.jpg" -mf type=jpg:fps=15 -o output.mpg -speed 1 -ofps 15 -ovc lavc -lavcopts vcodec=mpeg2video:vbitrate=2500 -oac copy -of mpeg

if the fps is 30 use:
mencoder "mf://*.jpg" -mf type=jpg:fps=30 -o output.mpg -speed 1 -ofps 30 -ovc lavc -lavcopts vcodec=mpeg2video:vbitrate=2500 -oac copy -of mpeg

This command produced an mpg named output.mpg. You will also have to have the library mencoder downloaded

So the command should look like
python visualizer2.py (imu_data.csv) (video.mpg)

You should also have the visualizer and segment file in the same folder since the visualizer file depends on the segment file.

Features of the visualizer:
The video has the ability to pause and unpause. When you pause, the graphs automatically zoom in on the time you paused, with a 2 second margin. If you play while the graph is zoomed in, the graph will update along the time frame, staying at the the same zoomed in limits. The back button allows you to go 5 seconds back. The forward button causes you to go 5 seconds forward.

The toolbar has features like zooming in, returning to the original graph, etc ...