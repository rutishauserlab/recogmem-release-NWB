from pynwb import NWBFile
from pynwb import NWBHDF5IO
import demoHelper

# Create the NWB file
nwb = NWBFile(...)

#session: 'TWH103_111918'
NOID = 144

#Get all Spike Times
allSpikeTimes = demoHelper.getSpikeTimesAllCells(...)

for cluster in allSpikeTimes.keys():
    # Add spike times to Units Table
    nwb.add_unit(id = int(cluster), spike_times = allSpikeTimes[cluster][0])


#Add Trial(s) information (Learning)
events_learn_stim_on = [4.218311e+09, 4.222039e+09, ...]
events_learn_stim_off = [4.219308e+09, 4.223034e+09, ...]
...

for i in range(len(events_learn_stim_on)):
    nwb.add_trial(  stim_on = events_learn_stim_on[i],
                    stim_off = events_learn_stim_off[i],
                    ...)

#Add Trial(s) information (Recognition)
events_recog_stim_on = [5.222291e+09, 5.229686e+09, ...]
events_recog_stim_off = [5.223292e+09, 5.230683e+09, ...]
...

for i in range(len(events_recog_stim_on)):
    nwb.add_trial(  stim_on = events_recog_stim_on[i],
                    stim_off = events_recog_stim_off[i],
                    ...)

io = NWBHDF5IO('TWH103_111918.nwb', mode='w')
io.write(nwb)
io.close()