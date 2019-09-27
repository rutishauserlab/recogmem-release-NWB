

import demoHelper
from pynwb import NWBFile
from pynwb import NWBHDF5IO
from datetime import datetime

# Create the NWB file
nwb = NWBFile(
        session_description = 'New/Old Export Events Demo',
        identifier = 'Demo',
        session_start_time = datetime.strptime('2019-06-04', '%Y-%m-%d'),
        file_create_date = datetime.now()
        )

NOID = 5
basepath = 'C:\\Users\\chandravadn1\\Desktop\\code\\data\\Faraut et al 2018\\'
iniFileName = 'C:\\svnwork\\nwbsharing\\events\\newolddelay\\defineNOsessions_release.ini'

#Get all Spike Times
allSpikeTimes = demoHelper.getSpikeTimesAllCells(basepath, iniFileName, NOID)

for cluster in allSpikeTimes.keys():
    # Add spike times to Units Table
    nwb.add_unit(id = int(cluster), spike_times = allSpikeTimes[cluster][0])

io = NWBHDF5IO('demo.nwb', mode='w')
io.write(nwb)
io.close()