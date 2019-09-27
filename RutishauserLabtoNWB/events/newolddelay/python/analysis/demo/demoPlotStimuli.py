'''Plot Stimuli from NWB files'''


from pathlib import Path
import os
import sys
from pynwb import NWBHDF5IO
import cv2
import numpy as np
import re

def plotStimuli(nwbFilePath):
    # Input Path Here
    #nwbFilePath = ('V:/LabUsers/chandravadian/NWB Data/p/P9HMH_NOID5.nwb')
    #session = 'P9HMH_NOID5.nwb'  # 'P42HMH.nwb'

    plotStimuli = range(0, 100) # Learn = [0, 100] ; Recog = [101, 200]

    # ===============================================================
    # ===============================================================


    if not os.path.exists(nwbFilePath):
        print('This file does not exist: {}'.format(nwbFilePath))
        sys.exit(-1)

    # Read NWB file
    io = NWBHDF5IO(nwbFilePath, mode='r')
    nwbfile = io.read()

    # ************* Helper FXNs ***************************

    def check(text):
        return int(text) if text.isdigit() else text

    def natural_keys(text):

        return [ check(c) for c in re.split(r'(\d+)', text) ]

    # *****************************************************

    try:
        # Get Stimuli from NWB file
        stimulus_keys = nwbfile.stimulus.keys()
        stimuli = []
        for stimuli_names in stimulus_keys:

            stimuli.append(stimuli_names)

        stimuli.sort(key=natural_keys)

    except:
        print('Error in getting stimuli keys')
        sys.exit(-1)


    for eachStim in plotStimuli:

        img = np.asarray(nwbfile.stimulus['StimulusPresentation'].data)
        # Check Matrix Dimensions
        img_size = np.shape(img[eachStim])
        if not img_size[-1] == 3:
            img = img.transpose()

        # Get Stimuli Category Name
        stim = nwbfile.trials['category_name'].data
        # Show Image
        cv2.moveWindow(stim[eachStim], 100, 100)
        cv2.imshow(stim[eachStim], img[eachStim])
        # cv2.moveWindow(stim[eachStim], 910, 0)
        # Wait for a key press
        print("=========  Press any key to move to the next image. Press 'esc' to quit. ================")
        key = cv2.waitKey(0)
        if key == 27:
            cv2.destroyAllWindows()
            sys.exit(0)
        else:
            cv2.destroyAllWindows()


