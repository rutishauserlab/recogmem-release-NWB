
import os.path
from pynwb import NWBHDF5IO
from pynwb import NWBFile, TimeSeries
from datetime import datetime
import pandas as pd
from scipy.io import loadmat
import numpy as np


# Set Path to Data (e.g., 'eventsRaw.mat')
eventPath = 'C:\\Users\\chandravadn1\\Desktop\\code\\data\\Faraut et al 2018\\Data\\events\\P9HMH_032306\\NO\\eventsRaw.mat'

# Create the NWB file
nwb = NWBFile(
        session_description = 'New/Old Export Events Demo',
        identifier = 'Demo',
        session_start_time = datetime.strptime('2019-06-04', '%Y-%m-%d'),
        file_create_date = datetime.now()
        )

events = pd.DataFrame(loadmat(eventPath)['events'])
TIME_SCALING = 10**6 #  Convert uS to seconds
nwbEvents = TimeSeries(name = 'events', unit = 'NA', data = np.asarray(events[1].values),
                       timestamps = np.asarray(events[0].values)/TIME_SCALING, description = 'Export events to NWB file')
nwb.add_acquisition(nwbEvents)
io = NWBHDF5IO('demo.nwb', mode='w')
io.write(nwb)
io.close()
