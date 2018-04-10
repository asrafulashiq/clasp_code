# clasp_code

## Installation

1.  ##### Frame extraction :
First, all the frames of the video have to be extracted into a folder by running save_all_frames.m. Here, path of source mp4 file and destination path should be provided.


2. ##### Optical flow :
Optical flow is extracted by running py_flow/main.py. For more help, see this repo:https://github.com/pathak22/pyflow
I failed to run the flow extraction files in my windows pc. So, I created a linux virtual machine, and succeeded to run it there.

3. Run install.m to install matconvnet and other external libraries.

4. Run setup.py to add paths in matlab.

5. Run main.m to run camera 9 and 2. I commented out camera 11 and 13, because you need bin and people information of camera 9 to run camera 11 and 13. 
