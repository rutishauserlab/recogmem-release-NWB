'''  Example Script that Plots Waveforms from NWB File'''


import matplotlib.pyplot as plt
import numpy as np
import os
import sys
from pynwb import NWBHDF5IO

def plotWaveforms(nwbFilePath, channel):

    # Input Path Here
    #nwbBasePath = Path('V:/LabUsers/chandravadian/NWB Data/test/')
    #session = 'P9HMH_032306.nwb'
    #channel = [1:200]
    # =====================================================
    # =====================================================
    if not os.path.exists(nwbFilePath):
        print('This file does not exist: {}'.format(nwbFilePath))
        sys.exit(-1)

    # Read NWB file
    io = NWBHDF5IO(nwbFilePath, mode='r')
    nwbfile = io.read()

    # get Waveform Means
    allwaveformLearn = np.asarray(nwbfile.units['waveform_mean_encoding'].data)
    allwaveformRecog = np.asarray(nwbfile.units['waveform_mean_recognition'].data)
    # Choose Which Channel Index to Plot

    waveformLearn = allwaveformLearn[channel, :]
    waveformRecog = allwaveformLearn[channel, :]

    # Plot
    #Plot Learning
    plt.subplot(1, 2, 1)
    plt.plot(range(len(waveformLearn)), waveformLearn, color = 'blue', marker = 'o', linestyle='dashed',
            linewidth=1, markersize=3)
    plt.title('Waveform Mean Learning, session: {}'.format(nwbfile.identifier))
    plt.xlabel('time (in ms)')
    plt.ylabel('\u03BCV')

    #Plot Recog
    plt.subplot(1, 2, 2)
    plt.plot(range(len(waveformRecog)), waveformRecog, color = 'green', marker = 'o', linestyle='dashed',
            linewidth=1, markersize=3)
    plt.title('Waveform Mean Recognition, session: {}'.format(nwbfile.identifier))
    plt.xlabel('time (in ms)')
    #plt.ylabel('\u03BCV')

    #Show Plot
    plt.show()

