
import os.path
from path import Path
import os
import sys
import configparser
from scipy.io import loadmat
import numpy as np


def getSpikeTimesAllCells(basepath, iniFileName, NOID):

    '''
    Purpose:


    Input(s):
        - basepath (str): The session ID (e.g., 5)
        - iniFileName (str):
        - sessionID (str): sessionID of the session (e.g., 'H09') (see defineNOsessions.ini)

    Returns:
        all_spikes (dict):

         '''

    #  Check config file path
    filename = Path(iniFileName)
    if not os.path.exists(filename):
        print('This file does not exist: {}'.format(filename))
        print("Check filename/and or directory")
        print("Exiting.......")
        sys.exit(-1)

    # Read the config file
    try:
        # initialze the ConfigParser() class
        config = configparser.ConfigParser()
        # read .ini file
        config.read(filename)
    except:
        print('Failed to read the config file..')
        print('Does this file exist: {}'.format(os.path.exists(filename)))
        sys.exit(-1)


    for section in config.sections():
            if NOID == int(section):
                for value in config[section]:
                    if value.lower() == 'nosessions.session':
                        session = config[section][value].strip("'")
                    if value.lower() == 'nosessions.taskdescr':
                        taskDescr = config[section][value].strip("'")

    #Get the basepathSorted
    try:
        basepathSorted = os.path.join(basepath, 'Data', 'sorted', session, taskDescr)
        if not os.path.exists(basepathSorted):
            print('This file does not exist: {}'.format(basepathSorted))
            sys.exit(-1)
    except:
        print('Error in getting basepathSorted, check input arguments')
        sys.exit(-1)

    # Get the basepathBrainArea
    brainAreaFile = Path(os.path.join(basepath, 'Data', 'events', session, taskDescr, 'brainArea.mat'))
    if not os.path.exists(brainAreaFile):
        print('This file does not exist: {}'.format(brainAreaFile))
        sys.exit(-1)
    else:
        brainArea = loadmat(brainAreaFile)

    channels = np.unique(brainArea['brainArea'][:, 0])

    #  Create dictionary of spikes
    all_spikes = {}

    for channel in range(0, len(channels)):
        sortedCellName = 'A{}_cells.mat'.format(channels[channel])
        basepathSortedCell = os.path.join(basepathSorted,sortedCellName)

        if not os.path.exists(basepathSorted):
            print('This file does not exist: {}'.format(basepathSorted))
            sys.exit(-1)

        sortedCell = loadmat(basepathSortedCell)
        spikes = sortedCell['spikes']


        for cluster in np.unique(spikes[:, 0]):
            indexofSpikes = np.where(spikes[:, 0] == int(cluster))
            all_spikes[channels[channel]] = (spikes[indexofSpikes, 2]) #/10**6 #  Convert uS spike_times to seconds


    return all_spikes