from pynwb import NWBHDF5IO
import numpy as np

#NOID:144
session = 'TWH103_111918.nwb'

# Read NWB file
io = NWBHDF5IO(session, mode='r')
nwbfile = io.read()

#Get Each channel
channels = np.asarray(nwbfile.units['electrodes'].data)

# Get Units Information
channel_ids = np.asarray(nwbfile.units['channel_id'].data)
for i in range(len(channels)):
    spike_timestamps = np.asarray(nwbfile.units.get_unit_spike_times(channels[i]))

    # Setup Neuron() structure
    neurons = Neuron()
    neurons.spike_timestamps = spike_timestamps
    neurons.channel_ids = channel_ids[i]
    ...

# Get Trial Structure
stim_on = np.asarray(nwbfile.trials['start_time'].data)
stim_off = np.asarray(nwbfile.trials['stop_time'].data)
category_name = np.asarray((nwbfile.trials['category_name'].data)).astype(str)
...

# Setup Trial() structure
for i in range(len(category_name)):
    trial = Trial()
    trial.stim_on = stim_on[i]
    trial.stim_off = stim_off[i]
    trial.category_name = category_name[i]

#Plot Raster/PSTH for a VS neuron
vs_neurons = []
for neuron in range(len(neurons)):
    if neurons[neuron].vs_test() <= 0.05:
        vs_neurons.append(neurons[neuron])

vs_neurons[2].raster_psth(cell_type= 'visual', smooth=True, bin_size = 1)


