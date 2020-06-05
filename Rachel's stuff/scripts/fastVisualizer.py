import pandas as pd
import numpy as np
import matplotlib.backends.backend_tkagg as tkagg
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg, NavigationToolbar2TkAgg
import cv2
from PIL import Image
from PIL import ImageTk
from fastSegment import *
import tkinter
from tkinter.ttk import *
import sys
from matplotlib.figure import Figure
from matplotlib.collections import LineCollection

class App:
    #relevant variables pertaining to data from bags
    global gyrofile, gyro_df
    #relevant variables pertaining to data from video
    global video_file, frame_list, current_frame, fps
    
    gyrofile = read_file(sys.argv[1])
    gyro_df = get_gyro_df(gyrofile)
    video_file = sys.argv[2]
    frame_list = []
    current_frame = 0
    #fps = 15 #I don't think this does anything; it seems to be overwritten later in an intelligent way

    def __init__(self, master):
        frame = tkinter.Frame(master)
        
        #calculate what the size of the graphs should be
        self.width = int(master.winfo_screenwidth()//96//3)
        self.height = master.winfo_screenheight()//96//2-.25
       
        self.fig = Figure(figsize=(self.width, self.height))
        self.ax = self.fig.add_subplot(111)
        self.fig2 = Figure(figsize=(self.width, self.height))
        self.ax2 = self.fig2.add_subplot(111)
        self.fig3 = Figure(figsize=(self.width, self.height))
        self.ax3 = self.fig3.add_subplot(111)

        plot_gyro_df(self, gyro_df)
        #initialize vertical lines
        self.ln1 = self.ax.axvline(0,0,.1)
        self.ln2 = self.ax2.axvline(0,0,.1)
        self.ln3 = self.ax3.axvline(0,0,.1)
        #first graph
        self.canvas1 = FigureCanvasTkAgg(self.fig,master=master)
        #self.canvas1.create_line(10,10,50,50)
        self.canvas1.draw() #self.canvas1.show()
        self.canvas1.get_tk_widget().grid(row=2, column=0, rowspan=5, columnspan=5,sticky='nesw')
         
        self.canvas1.draw() #self.canvas1.show()
        
        #3rd graph on top
        self.canvas3 = FigureCanvasTkAgg(self.fig3, master=master)
        self.canvas3.draw() #self.canvas3.show()
        self.canvas3.get_tk_widget().grid(row=2, column=14, rowspan=5, columnspan=5,sticky='nesw')
        
        #2nd graph on top
        self.canvas2 = FigureCanvasTkAgg(self.fig2,master=master)
        self.canvas2.draw() #self.canvas2.show()
        self.canvas2.get_tk_widget().grid(row=2, column=7, rowspan=5, columnspan=5,sticky='nesw')

        #toolbars for nagivating the graphs
        toolbar_frame1 = Frame(root)
        toolbar_frame1.grid(row=8,column=0, columnspan=5)
        toolbar1 = NavigationToolbar2TkAgg(self.canvas1, toolbar_frame1)

        toolbar_frame2 = Frame(root)
        toolbar_frame2.grid(row=8, column=12, columnspan=5)
        toolbar2 = NavigationToolbar2TkAgg(self.canvas2, toolbar_frame2)
        
        toolbar_frame3 = Frame(root)
        toolbar_frame3.grid(row=8, column=6, columnspan=5)
        toolbar3 = NavigationToolbar2TkAgg(self.canvas3, toolbar_frame3)

        zLabelFrame = Frame(root)
        zLabel = Label(zLabelFrame, text="Z velocity").pack()
        zLabelFrame.grid(row=0,column=0,columnspan=5,sticky='nesw')

        videoLabelFrame = Frame(root)
        videoLabel = Label(videoLabelFrame, text="Live video").pack()
        videoLabelFrame.grid(row=9,column=0,columnspan=5,sticky='nesw')
        
        xLabelFrame = Frame(root)
        xLabel = Label(xLabelFrame, text="Y Linear Acceleration").pack()
        xLabelFrame.grid(row=0,column=7,columnspan=5,sticky='nesw')
        
        yLabelFrame = Frame(root)
        yLabel = Label(yLabelFrame, text="W orientation").pack()
        yLabelFrame.grid(row=0,column=14,columnspan=5,sticky='nesw')

        #video
        imageFrame = Frame(root)
        imageFrame.grid(row=10, column=0, rowspan=5, columnspan=5, sticky='nesw')        
        
        self.pause = False
        self.back = False
        self.forward = False
        self.nonempty = True #If true, means everything's fine. If not, the reader hit the end of the file. Why do we care to store this in the function?
        self.backFrame = 0 #backFrame keeps track of how many frames forward or backwards to read based off where it stopped off reading the frames

        global fps
        def on_clicked_pause():
            self.pause = True
            
            #zoom in on graph with 2 second margin
            seconds = (current_frame + self.backFrame)*1.0/(fps)
            x = 0
            if(seconds - 2 > 0):
                x = seconds - 2.0
            y = seconds + 2.0
            self.ax.set_xlim([x,y])
            self.ax2.set_xlim([x,y])
            self.ax3.set_xlim([x,y])
            self.ln1.set_data([seconds,seconds], self.ax.get_ylim())
            self.ln2.set_data([seconds,seconds], self.ax2.get_ylim())
            self.ln3.set_data([seconds,seconds], self.ax3.get_ylim())
            self.canvas1.draw()
            self.canvas2.draw()
            self.canvas3.draw()
   

        def on_clicked_play():
            if(self.pause):
                self.pause = False
                show_frame()

        def on_clicked_back():
            self.back = True #Should be "if backFrame < 0, set self.back=True and self.forward=False" after decrementing backFrame, but no one's going to click both buttons inside one update step
            self.backFrame -=fps*5
            if not self.nonempty: #What is this doing???
                self.nonempty = True
                show_frame()

        def on_clicked_forward():
            self.backFrame +=fps*5
            if(self.backFrame > 0):
                self.back = False
                self.forward = True

        buttonFrame = Frame(root)
        buttonFrame.grid(row=11, column=7, sticky='nesw')
        timeText = tkinter.StringVar()
        timeText.set("0:00")
        timeLabel = Label(buttonFrame, textvariable=timeText).pack()
        pauseButton = Button(buttonFrame, text="pause", command=on_clicked_pause).pack()
        playButton = Button(buttonFrame, text="play", command=on_clicked_play).pack()
        backButton = Button(buttonFrame, text="back", command=on_clicked_back).pack()
        forwardButton = Button(buttonFrame, text="forward", command=on_clicked_forward).pack()
        
        #Capture video frames
        lmain = Label(imageFrame)
        lmain.grid(row=10, column=0, rowspan=5,columnspan=5, sticky='nesw')
        global video_file
        cap = cv2.VideoCapture(video_file)
        fps = int(cap.get(cv2.CAP_PROP_FPS))

        #Call this to start updating the plot
        #Works by recursively calling itself after a delay, stopping if you pause (hence the need to restart it when you hit play)
        def show_frame():

            #Recursively call this function after some delay
            #First number is that time delay (at minimum; if the rest of this function is slow, it may delay the recursive call further)
            #Should be 1000/fps, not fps.
            #Fps seemed to run in real time experimentally because we were calling this AFTER all the heavy processing. We want to start the clock BEFORE updating images so we don't add an extra delay on top of everything

            lmain.after_id = lmain.after(1000//fps,show_frame)

            #if self.pause: #...except stop recursively calling this if we're paused or at the end of the file
            if self.pause or not self.nonempty: #...except stop recursively calling this if we're paused or at the end of the file
                lmain.after_cancel(lmain.after_id)
            
            global current_frame
            
            #If you've gone back far enough that the frame you need is already loaded
            if(self.back): #if pressed back
                if(current_frame + self.backFrame < 0):
                    self.backFrame = -(current_frame)
                frame = frame_list[current_frame + self.backFrame]
                self.backFrame += 1 #Decrease the buffer of already-read frames
                if (self.backFrame == 0): #If out of buffer, we'll need to go back to reading frames normally
                    self.back=False
                    
            #If you've gone forward past your current frame
            elif (self.forward): #if pressed forward, upload more frames if you need to
                self.nonempty, frame = cap.read()
                while(self.backFrame > 0):
                    if not self.nonempty: #Means you've hit the end of the file
                        frame = frame_list[-1]
                        break

                    current_frame +=1
                    #frame = cv2.flip(frame, 1) #Flip the frame horizontally??? Why are we doing this???
                    frame_list.append(frame)
                    self.backFrame -= 1
                    self.nonempty, frame = cap.read() #Does this skip a frame in the last step? Should be the first thing in the loop (before checking to break) instead, and remove from outside?

                self.forward = False #At this point, we've read enough new frames that we're up to date
    
            else: #continue reading from current position
                self.nonempty, frame = cap.read()
                if not self.nonempty:
                    frame = frame_list[-1]
                    
                #frame = cv2.flip(frame, 1) #Flip the frame horizontally??? Why are we doing this???
                frame_list.append(frame)
                current_frame += 1
            
            #update current time and graphs
            #This part updates the program's printed clock
            if((current_frame + self.backFrame) % fps == 0): #Fires every second
                if ((current_frame+self.backFrame)%(60*fps)//fps//10==0): #"If number of seconds < 10". Equivalent: "if (current + back)//fps % 60 < 10" for readability
                    timeText.set((str((current_frame+self.backFrame)//(60*fps)) + ":0" + str((current_frame+self.backFrame)%(60*fps)//fps)))
                else:
                    timeText.set((str((current_frame+self.backFrame)//(60*fps)) + ":" + str((current_frame+self.backFrame)%(60*fps)//fps)))
                
            #if zoomed in, update graphs every 6 frames
            if(current_frame + self.backFrame) % 6 == 0:
                seconds = (current_frame + self.backFrame)*1.0/fps #Current time in seconds; don't round
                x, y = self.ax.get_xlim() #Axis limits are [x, y]
                if(y-x <= 4.5): #If we're zoomed in
                    x = 0
                    if(seconds - 2 > 0): #Start at 2 seconds ago if that's a non-negative time
                        x = seconds - 2.0
                    y = seconds + 2.0 #End 2 seconds from now
                    self.ax.set_xlim([x,y])
                    self.ax2.set_xlim([x,y])
                    self.ax3.set_xlim([x,y])
                    #update vertical lines
                    self.ln1.set_data([seconds,seconds], self.ax.get_ylim())
                    #for some reason the second and third lines lag behind, so to fix the delay, put it slightly ahead
                    #can't really tell if it's supposed to be like this (since there is a slight delay in the the second and third given they're called in succession)
                    #if it is should lag behind, then simply change seconds2 to seconds
                    #seconds2 = seconds + 6.0/fps
                    self.ln2.set_data([seconds,seconds], self.ax2.get_ylim())
                    self.ln3.set_data([seconds, seconds], self.ax3.get_ylim())
                    self.canvas1.show()  #Other plots update in the callback for the axis change
                    self.canvas2.show()
                    self.canvas3.show()

            #update image on video
            cv2image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGBA)
            img = Image.fromarray(cv2image)
            imgtk = ImageTk.PhotoImage(image=img)
            lmain.imgtk = imgtk
            lmain.configure(image=imgtk)

            #Stop iterating at end of file
            if not self.nonempty:
                self.pause = True

        #Call show_frame once at the end of initialization to start the video playing
        show_frame()


#Call the initialization and start the mainloop (loop forever responding to user input)
root = tkinter.Tk()
root.resizable(width=True, height=True)
width, height = root.winfo_screenwidth(), root.winfo_screenheight()
root.geometry('%dx%d+0+0' % (width,height))
app = App(root)
root.mainloop()
