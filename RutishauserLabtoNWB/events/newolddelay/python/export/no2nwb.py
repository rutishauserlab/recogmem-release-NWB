# ---------------------------------------------------------------------------------------------------------------------
#         Rutishauser Lab, Cedars-Sinai Medical Center/Caltech, 2019.  http://www.rutishauserlab.org/
# ----------------------------------------------------------------------------------------------------------------------
#  Overview:
#     This file (no2nwb.py) creates the NWB file object with the data and associated meta-data from the
#     new/old recognition task.
#
#
#
#
# ----------------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------

import numpy as np
from scipy.io import loadmat
import os
from pynwb import NWBFile, TimeSeries
from pynwb.misc import AnnotationSeries
from pynwb.image import OpticalSeries
from pynwb.file import Subject
import datetime
import cv2
import configparser
import os.path
from datetime import datetime, timezone


# ----------------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------

def no2nwb(NOData, session_use, subjects_ini, path_to_data):

    '''
       Purpose:
           Import the data and associated meta-data from the new/old recognition dataset into an
           NWB file. Each of the features of the dataset, such as the events (i.e., TTLs) or mean waveform, are
           compartmentalized to the appropriate component of the NWB file.


    '''



    # Time scaling (covert uS -----> S for NWB file)
    TIME_SCALING = 10**6

    # Prepare the NO data that will be coverted to the NWB format

    session = NOData.sessions[session_use]
    events = NOData._get_event_data(session_use, experiment_type='All')
    cell_ids = NOData.ls_cells(session_use)
    experiment_id_learn = session['experiment_id_learn']
    experiment_id_recog = session['experiment_id_recog']
    task_descr = session['task_descr']

    # Get the metadata for the subject
    # ============ Read Config File ()
    # load config file (subjects == config file)

    #  Check config file path
    filename = subjects_ini
    if not os.path.exists(filename):
        print('This file does not exist: {}'.format(filename))
        print("Check filename/and or directory")

    # Read the config file
    try:
        # initialze the ConfigParser() class
        config = configparser.ConfigParser()
        # read .ini file
        config.read(filename)
    except:
        print('Failed to read the config file..')
        print('Does this file exist: {}'.format(os.path.exists(filename)))

    #  Read Meta-data from INI file.
    for section in config.sections():
        if session_use == int(section):
            session_id = int(section) #  The New/Old ID for the session
            #Get the session ID
            for value in config[section]:
                if value.lower() == 'nosessions.age':
                    age = int(config[section][value])
                if value.lower() == 'nosessions.diagnosiscode':
                    epilepsyDxCode = config[section][value]
                    epilepsyDx = getEpilepsyDx(int(epilepsyDxCode))
                if value.lower() == 'nosessions.sex':
                    sex = config[section][value].strip("'")
                if value.lower() == 'nosessions.id':
                    ID = config[section][value].strip("'")
                if value.lower() == 'nosessions.session':
                    pt_session = config[section][value].strip("'")
                if value.lower() == 'nosessions.date':
                    unformattedDate = config[section][value].strip("'")
                    date = datetime.strptime(unformattedDate, '%Y-%m-%d')
                    finaldate = date.replace(hour = 0, minute = 0)
                if value.lower() == 'nosessions.institution':
                    institution = config[section][value].strip("'")
                if value.lower() == 'nosessions.la':
                    LA = config[section][value].strip("'").split(',')
                    if LA[0] == 'NaN':
                        LA_x = np.nan
                        LA_y = np.nan
                        LA_z = np.nan
                    else:
                        LA_x = float(LA[0])
                        LA_y = float(LA[1])
                        LA_z = float(LA[2])
                if value.lower() == 'nosessions.ra':
                    RA = config[section][value].strip("'").split(',')
                    if RA[0] == 'NaN':
                        RA_x = np.nan
                        RA_y = np.nan
                        RA_z = np.nan
                    else:
                        RA_x = float(RA[0])
                        RA_y = float(RA[1])
                        RA_z = float(RA[2])
                if value.lower() == 'nosessions.lh':
                    LH = config[section][value].strip("'").split(',')
                    if LH[0] == 'NaN':
                        LH_x = np.nan
                        LH_y = np.nan
                        LH_z = np.nan
                    else:
                        LH_x = float(LH[0])
                        LH_y = float(LH[1])
                        LH_z = float(LH[2])
                if value.lower() == 'nosessions.rh':
                    RH = config[section][value].strip("'").split(',')
                    if RH[0] == 'NaN':
                        RH_x = np.nan
                        RH_y = np.nan
                        RH_z = np.nan
                    else:
                        RH_x = float(RH[0])
                        RH_y = float(RH[1])
                        RH_z = float(RH[2])
                if value.lower() == 'nosessions.system':
                    signalSystem = config[section][value].strip("'")

    # =================================================================



    print('=======================================================================')
    print('session use: {}'.format(session_id))
    print('age: {}'.format(age))
    print('epilepsy_diagnosis: {}'.format(epilepsyDx))

    nwb_subject = Subject(age = str(age), description = epilepsyDx,
                          sex = sex, species = 'Human',
                          subject_id=pt_session[:pt_session.find('_')])

    # Create the NWB file
    nwbfile = NWBFile(
        #source='https://datadryad.org/bitstream/handle/10255/dryad.163179/RecogMemory_MTL_release_v2.zip',
        session_description = 'New/Old recognition task for ID: {}. '.format(session_id),
        identifier = '{}_{}'.format(ID, session_use),
        session_start_time = finaldate, #default session start time
        file_create_date = datetime.now(),
        experiment_description = 'The data contained within this file describes a new/old recogntion task performed in '
                                 'patients with intractable epilepsy implanted with depth electrodes and Behnke-Fried '
                                 'microwires in the human Medical Temporal Lobe (MTL).',
        institution = institution,
        keywords = ['Intracranial Recordings', 'Intractable Epilepsy', 'Single-Unit Recordings', 'Cognitive Neuroscience',
                    'Learning', 'Memory', 'Neurosurgery'],
        related_publications = 'Faraut et al. 2018, Scientific Data; Rutishauser et al. 2015, Nat Neurosci;',
        lab = 'Rutishauser',
        subject = nwb_subject,
        data_collection = 'learning: {}, recognition: {}'.format(session['experiment_id_learn'], session['experiment_id_recog'])
    )


    # Add events and experiment_id acquisition
    events_description = (""" The events coorespond to the TTL markers for each trial. For the learning trials, the TTL markers 
            are the following: 55 = start of the experiment, 1 = stimulus ON, 2 = stimulus OFF, 3 = Question Screen Onset [“Is this an animal?”], 
            20 = Yes (21 = NO) during learning, 6 = End of Delay after Response, 66 = End of Experiment. For the recognition trials, 
            the TTL markers are the following: 55 = start of experiment, 1 = stimulus ON, 2 = stimulus OFF, 3 = Question Screen Onset [“Have you seen this image before?”], 
            31:36 = Confidence (Yes vs. No) response [31 (new, confident), 32 (new, probably), 33 (new, guess), 34 (old, guess), 
            35 (old, probably), 36 (old, confident)], 66 = End of Experiment""")

    event_ts = AnnotationSeries(name = 'events', data = np.asarray(events[1].values).astype(str), timestamps=np.asarray(events[0].values)/TIME_SCALING,
                                description = events_description)


    experiment_ids_description = ("""The experiment_ids coorespond to the encoding (i.e., learning) or recogniton trials. The learning trials are demarcated by: {}. The recognition trials are demarcated by: {}. """.format(experiment_id_learn,experiment_id_recog))

    experiment_ids = TimeSeries(name='experiment_ids', unit='NA', data=np.asarray(events[2]),
                                timestamps=np.asarray(events[0].values)/TIME_SCALING, description = experiment_ids_description)

    nwbfile.add_acquisition(event_ts)
    nwbfile.add_acquisition(experiment_ids)

    # Add stimuli to the NWB file
    # Get the first cell from the cell list
    cell = NOData.pop_cell(session_use, NOData.ls_cells(session_use)[0], path_to_data)
    trials = cell.trials
    stimuli_recog_path = [trial.file_path_recog for trial in trials]
    stimuli_learn_path = [trial.file_path_learn for trial in trials]



    # Add epochs and trials: storing start and end times for a stimulus

    # First extract the category ids and names that we need
    # The metadata for each trials will be store in a trial table

    cat_id_recog = [trial.category_recog for trial in trials]
    cat_name_recog = [trial.category_name_recog for trial in trials]
    cat_id_learn = [trial.category_learn for trial in trials]
    cat_name_learn = [trial.category_name_learn for trial in trials]

    # Extract the event timestamps
    events_learn_stim_on = events[(events[2] == experiment_id_learn) & (events[1] == NOData.markers['stimulus_on'])]
    events_learn_stim_off = events[(events[2] == experiment_id_learn) & (events[1] == NOData.markers['stimulus_off'])]
    events_learn_delay1_off = events[(events[2] == experiment_id_learn) & (events[1] == NOData.markers['delay1_off'])]
    events_learn_delay2_off = events[(events[2] == experiment_id_learn) & (events[1] == NOData.markers['delay2_off'])]
    events_learn = events[(events[2] == experiment_id_learn)]
    events_learn_response = []
    events_learn_response_time = []
    for i in range(len(events_learn[0])):
        if (events_learn.iloc[i, 1] == NOData.markers['response_learning_animal']) or (events_learn.iloc[i, 1] == NOData.markers['response_learning_non_animal']):
            events_learn_response.append(events_learn.iloc[i, 1]-20)
            events_learn_response_time.append(events_learn.iloc[i, 0])



    events_recog_stim_on = events[(events[2] == experiment_id_recog) & (events[1] == NOData.markers['stimulus_on'])]
    events_recog_stim_off = events[(events[2] == experiment_id_recog) & (events[1] == NOData.markers['stimulus_off'])]
    events_recog_delay1_off = events[(events[2] == experiment_id_recog) & (events[1] == NOData.markers['delay1_off'])]
    events_recog_delay2_off = events[(events[2] == experiment_id_recog) & (events[1] == NOData.markers['delay2_off'])]
    events_recog = events[(events[2] == experiment_id_recog)]
    events_recog_response = []
    events_recog_response_time = []
    for i in range(len(events_recog[0])):
        if ((events_recog.iloc[i, 1] == NOData.markers['response_1']) or (events_recog.iloc[i, 1] == NOData.markers['response_2']) or
            (events_recog.iloc[i, 1] == NOData.markers['response_3']) or (events_recog.iloc[i, 1] == NOData.markers['response_4']) or
            (events_recog.iloc[i, 1] == NOData.markers['response_5']) or (events_recog.iloc[i, 1] == NOData.markers['response_6'])):
                events_recog_response.append(events_recog.iloc[i, 1])
                events_recog_response_time.append(events_recog.iloc[i, 0])


    # Extract new_old label
    new_old_recog = [trial.new_old_recog for trial in trials]
    # Create the trial tables

    nwbfile.add_trial_column('stim_on_time', 'The Time when the Stimulus is Shown')
    nwbfile.add_trial_column('stim_off_time', 'The Time when the Stimulus is Off')
    nwbfile.add_trial_column('delay1_time', 'The Time when Delay1 is Off')
    nwbfile.add_trial_column('delay2_time', 'The Time when Delay2 is Off')
    nwbfile.add_trial_column('stim_phase', 'Learning/Recognition Phase During the Trial')
    nwbfile.add_trial_column('stimCategory', 'The Category ID of the Stimulus')
    nwbfile.add_trial_column('category_name', 'The Category Name of the Stimulus')
    nwbfile.add_trial_column('external_image_file', 'The File Path to the Stimulus')
    nwbfile.add_trial_column('new_old_labels_recog', '''The Ground truth Labels for New or Old Stimulus. 0 == Old Stimuli 
                            (presented during the learning phase), 1 = New Stimuli (not seen )'during learning phase''')
    nwbfile.add_trial_column('response_value', 'The Response for Each Stimulus')
    nwbfile.add_trial_column('response_time', 'The Response Time for each Stimulus')

    range_recog = np.amin([len(events_recog_stim_on), len(events_recog_stim_off), len(events_recog_delay1_off),
                           len(events_recog_delay2_off)])
    range_learn = np.amin([len(events_learn_stim_on), len(events_learn_stim_off), len(events_learn_delay1_off),
                           len(events_learn_delay2_off)])

    # Iterate the event list and add information into each epoch and trial table
    for i in range(range_learn):


        nwbfile.add_trial(start_time=(events_learn_stim_on.iloc[i][0])/(TIME_SCALING),
                          stop_time=(events_learn_delay2_off.iloc[i][0])/(TIME_SCALING),
                          stim_on_time=(events_learn_stim_on.iloc[i][0])/(TIME_SCALING),
                          stim_off_time=(events_learn_stim_off.iloc[i][0])/(TIME_SCALING),
                          delay1_time=(events_learn_delay1_off.iloc[i][0])/(TIME_SCALING),
                          delay2_time=(events_learn_delay2_off.iloc[i][0])/(TIME_SCALING),
                          stim_phase='learn',
                          stimCategory=cat_id_learn[i],
                          category_name=cat_name_learn[i],
                          external_image_file=stimuli_learn_path[i],
                          new_old_labels_recog='NA',
                          response_value = events_learn_response[i],
                          response_time = (events_learn_response_time[i])/(TIME_SCALING)
                         )

    for i in range(range_recog):


        nwbfile.add_trial(start_time=events_recog_stim_on.iloc[i][0]/(TIME_SCALING),
                          stop_time=events_recog_delay2_off.iloc[i][0]/(TIME_SCALING),
                          stim_on_time=events_recog_stim_on.iloc[i][0]/(TIME_SCALING),
                          stim_off_time=events_recog_stim_off.iloc[i][0]/(TIME_SCALING),
                          delay1_time=events_recog_delay1_off.iloc[i][0]/(TIME_SCALING),
                          delay2_time=events_recog_delay2_off.iloc[i][0]/(TIME_SCALING),
                          stim_phase='recog',
                          stimCategory=cat_id_recog[i],
                          category_name=cat_name_recog[i],
                          external_image_file=stimuli_recog_path[i],
                          new_old_labels_recog=new_old_recog[i]   ,
                          response_value=events_recog_response[i],
                          response_time = events_recog_response_time[i]/(TIME_SCALING))


    # Add the waveform clustering and the spike data.
    # Get the unique channel id that we will be iterate over
    channel_ids = np.unique([cell_id[0] for cell_id in cell_ids])

    # unique unit id
    unit_id = 0

    # Create unit columns
    nwbfile.add_unit_column('origClusterID', 'The original cluster id')
    nwbfile.add_unit_column('waveform_mean_encoding', 'The mean waveform for encoding phase.')
    nwbfile.add_unit_column('waveform_mean_recognition', 'The mean waveform for the recognition phase.')
    nwbfile.add_unit_column('IsolationDist', 'IsolDist')
    nwbfile.add_unit_column('SNR', 'SNR')
    nwbfile.add_unit_column('waveform_mean_sampling_rate', 'The Sampling Rate of Waveform')


    #Add Stimuli
    stimuli_presentation = []

    # Add stimuli learn
    counter = 1
    for path in stimuli_learn_path:
        if path == 'NA':
            continue
        folders = path.split('\\')

        path = os.path.join(path_to_data, 'Stimuli', folders[0], folders[1], folders[2])
        img = cv2.imread(path)
        resized_image = cv2.resize(img, (300, 400))
        stimuli_presentation.append(resized_image)




    # Add stimuli recog
    counter = 1
    for path in stimuli_recog_path:
        folders = path.split('\\')
        path = os.path.join(path_to_data, 'Stimuli', folders[0], folders[1], folders[2])
        img = cv2.imread(path)
        resized_image = cv2.resize(img, (300, 400))
        stimuli_presentation.append(resized_image)
        name = 'stimuli_recog_' + str(counter)



    # Add stimuli to OpticalSeries
    stimulus_presentation_on_time = []

    for n in range(0, len(events_learn_stim_on)):
        stimulus_presentation_on_time.append(events_learn_stim_on.iloc[n][0] / (TIME_SCALING))

    for n in range(0, len(events_recog_stim_on)):
        stimulus_presentation_on_time.append(events_recog_stim_on.iloc[n][0] / (TIME_SCALING))


    name = 'StimulusPresentation'
    stimulus = OpticalSeries(name = name, data = stimuli_presentation, timestamps= stimulus_presentation_on_time[:], orientation = 'lower left',
                             format = 'raw', unit = 'meters', field_of_view = [.2, .3, .7], distance = 0.7, dimension = [300,400, 3])

    nwbfile.add_stimulus(stimulus)


    # Get Unit data
    all_spike_cluster_ids = []
    all_selected_time_stamps = []
    all_IsolDist = []
    all_SNR = []
    all_selected_mean_waveform_learn = []
    all_selected_mean_waveform_recog = []
    all_mean_waveform = []
    all_channel_id = []
    all_oriClusterIDs = []
    all_channel_numbers = []
    all_brain_area = []
    # Iterate the channel list

    # load brain area file
    brain_area_file_path = os.path.join(path_to_data, 'Data', 'events', session['session'],
                                        task_descr, 'brainArea.mat')

    try:
        brain_area_mat = loadmat(brain_area_file_path)
    except FileNotFoundError:
        print("brain_area_mat file not found")

    for channel_id in channel_ids:
        cell_name = 'A' + str(channel_id) + '_cells.mat'
        cell_file_path = os.path.join(path_to_data, 'Data', 'sorted', session['session'],
                                 task_descr, cell_name)

        try:
            cell_mat = loadmat(cell_file_path)
        except FileNotFoundError:
            print("cell mat file not found")
            continue

        spikes = cell_mat['spikes']
        meanWaveform_recog = cell_mat['meanWaveform_recog']
        meanWaveform_learn = cell_mat['meanWaveform_learn']
        IsolDist_SNR = cell_mat['IsolDist_SNR']


        spike_cluster_id = np.asarray([spike[1] for spike in spikes]) # Each Cluster ID of the spike
        spike_timestamps = (np.asarray([spike[2] for spike in spikes]))/(TIME_SCALING) # Timestamps of spikes for each ClusterID
        unique_cluster_ids = np.unique(spike_cluster_id)


        # If there are more than one cluster.
        for id in unique_cluster_ids:

            # Grab brain area
            brain_area = extra_brain_area(brain_area_mat, channel_id)

            selected_spike_timestamps = spike_timestamps[spike_cluster_id == id]
            IsolDist, SNR = extract_IsolDist_SNR_by_cluster_id(IsolDist_SNR, id)
            selected_mean_waveform_learn = extra_mean_waveform(meanWaveform_learn, id)
            selected_mean_waveform_recog = extra_mean_waveform(meanWaveform_recog, id)

            # If the mean waveform does not have 256 elements, we set the mean wave form to all 0
            if len(selected_mean_waveform_learn) != 256:
                selected_mean_waveform_learn = np.zeros(256)
            if len(selected_mean_waveform_recog) != 256:
                selected_mean_waveform_recog = np.zeros(256)

            mean_waveform = np.hstack([selected_mean_waveform_learn, selected_mean_waveform_recog])

            # Append unit data
            all_spike_cluster_ids.append(id)
            all_selected_time_stamps.append(selected_spike_timestamps)
            all_IsolDist.append(IsolDist)
            all_SNR.append(SNR)
            all_selected_mean_waveform_learn.append(selected_mean_waveform_learn)
            all_selected_mean_waveform_recog.append(selected_mean_waveform_recog)
            all_mean_waveform.append(mean_waveform)
            all_channel_id.append(channel_id)
            all_oriClusterIDs.append(int(id))
            all_channel_numbers.append(channel_id)
            all_brain_area.append(brain_area)

            unit_id += 1

    nwbfile.add_electrode_column(name = 'origChannel', description = 'The original channel ID for the channel')

    #Add Device
    device = nwbfile.create_device(name= signalSystem)

    # Add Electrodes (brain Area Locations, MNI coordinates for microwires)
    length_all_spike_cluster_ids = len(all_spike_cluster_ids)
    for electrodeNumber in range(0, len(channel_ids)):

        brainArea_location = extra_brain_area(brain_area_mat, channel_ids[electrodeNumber])

        if brainArea_location == 'RH': #  Right Hippocampus
            full_brainArea_Location = 'Right Hippocampus'

            electrode_name = '{}-microwires-{}'.format(signalSystem, channel_ids[electrodeNumber])
            description = "Behnke Fried/Micro Inner Wire Bundle (Behnke-Fried BF08R-SP05X-000 and WB09R-SP00X-0B6; Ad-Tech Medical)"
            location = full_brainArea_Location

            # Add electrode group
            electrode_group = nwbfile.create_electrode_group(electrode_name,
                                                             description=description,
                                                             location=location,
                                                             device=device)

            #Add Electrode
            nwbfile.add_electrode([channel_ids[electrodeNumber]],
                                x = RH_x, y = RH_y, z = RH_z,
                                imp = np.nan,
                                location = full_brainArea_Location, filtering = '300-3000Hz',
                                group = electrode_group, origChannel = channel_ids[electrodeNumber])

        if brainArea_location == 'LH':
            full_brainArea_Location = 'Left Hippocampus'

            electrode_name = '{}-microwires-{}'.format(signalSystem, channel_ids[electrodeNumber])
            description = "Behnke Fried/Micro Inner Wire Bundle (Behnke-Fried BF08R-SP05X-000 and WB09R-SP00X-0B6; Ad-Tech Medical)"
            location = full_brainArea_Location

            # Add electrode group
            electrode_group = nwbfile.create_electrode_group(electrode_name,
                                                             description=description,
                                                             location=location,
                                                             device=device)

            nwbfile.add_electrode([all_channel_id[electrodeNumber]],
                                  x = LH_x, y = LH_y, z = LH_z,
                                  imp = np.nan,
                                  location = full_brainArea_Location, filtering = '300-3000Hz',
                                  group = electrode_group, origChannel = channel_ids[electrodeNumber])
        if brainArea_location == 'RA':
            full_brainArea_Location = 'Right Amygdala'

            electrode_name = '{}-microwires-{}'.format(signalSystem, channel_ids[electrodeNumber])
            description = "Behnke Fried/Micro Inner Wire Bundle (Behnke-Fried BF08R-SP05X-000 and WB09R-SP00X-0B6; Ad-Tech Medical)"
            location = full_brainArea_Location

            # Add electrode group
            electrode_group = nwbfile.create_electrode_group(electrode_name,
                                                             description=description,
                                                             location=location,
                                                             device=device)

            nwbfile.add_electrode([all_channel_id[electrodeNumber]],
                                  x = RA_x, y = RA_y, z = RA_z,
                                  imp = np.nan,
                                  location=full_brainArea_Location, filtering = '300-3000Hz',
                                  group = electrode_group, origChannel = channel_ids[electrodeNumber])
        if brainArea_location == 'LA':
            full_brainArea_Location = 'Left Amygdala'

            electrode_name = '{}-microwires-{}'.format(signalSystem, channel_ids[electrodeNumber])
            description = "Behnke Fried/Micro Inner Wire Bundle (Behnke-Fried BF08R-SP05X-000 and WB09R-SP00X-0B6; Ad-Tech Medical)"
            location = full_brainArea_Location

            # Add electrode group
            electrode_group = nwbfile.create_electrode_group(electrode_name,
                                                             description=description,
                                                             location=location,
                                                             device=device)

            nwbfile.add_electrode([all_channel_id[electrodeNumber]],
                                    x = LA_x, y = LA_y, z = LA_z,
                                    imp = np.nan,
                                    location = full_brainArea_Location, filtering = '300-3000Hz',
                                    group = electrode_group, origChannel = channel_ids[electrodeNumber])


    # Create Channel list index
    channel_list = list(range(0, length_all_spike_cluster_ids))
    unique_channel_ids = np.unique(all_channel_id)
    length_ChannelIds = len(np.unique(all_channel_id))
    for yy in range(0,length_ChannelIds):
        a = np.array(np.where(unique_channel_ids[yy] == all_channel_id))
        b = a[0]
        c = b.tolist()
        for i in c:
            channel_list[i] = yy

    #Add WAVEFORM Sampling RATE
    waveform_mean_sampling_rate = [98.4*10**3]
    waveform_mean_sampling_rate_matrix = [waveform_mean_sampling_rate] * (length_all_spike_cluster_ids)


   # Add Units to NWB file
    for index_id in range(0, length_all_spike_cluster_ids):
        nwbfile.add_unit(id=index_id, spike_times=all_selected_time_stamps[index_id], origClusterID=all_oriClusterIDs[index_id],
                         IsolationDist=all_IsolDist[index_id], SNR=all_SNR[index_id], waveform_mean_encoding= all_selected_mean_waveform_learn[index_id],
                         waveform_mean_recognition = all_selected_mean_waveform_recog[index_id], electrodes=[channel_list[index_id]],
                         waveform_mean_sampling_rate = waveform_mean_sampling_rate_matrix[index_id])

    return nwbfile


def extract_IsolDist_SNR_by_cluster_id(IsoDist_SNR, cluster_id):
    for row in IsoDist_SNR[0]:
        if row[0][0][0] == cluster_id:
            return row[1][0][0], row[2][0][0]

def extra_mean_waveform(mean_waveforms, cluster_id):
    for mean_waveform in mean_waveforms[0]:
        if mean_waveform[0][0][0] == cluster_id:
            return mean_waveform[1][0]

def extra_brain_area(brain_area_mat, channel_id):
    area_mapping = {1: 'RH', 2: 'LH', 3: 'RA', 4: 'LA', 13: 'LH', 18: 'RH'}
    brain_area = brain_area_mat['brainArea'][brain_area_mat['brainArea'][:, 0] == channel_id, 3][0]
    return area_mapping[brain_area]


def getEpilepsyDx(diagnosticCode):
    '''
       Purpose:
           Get the Epilepsy Dx from the diagnostic Code. See defineNOsessions.ini to see a list of diagnostic codes

       Inputs:
           diagnosticCode (int): Diagnostsic Code for the Epilepsy Dx.

       Returns:
           Epilepsy Dx (str): The epilepsy diagnosis

    '''

    Dx = {0: 'Not Localized', 1: 'Right Mesial Temporal', 2: 'Left Mesial Temporal', 3: 'Right Neocortical Temporal',
          4: 'Left Neocortical Temporal', 5: 'Right Lateral Frontal', 6: 'Left Lateral Frontal',
          7: 'Bilateral Independent Temporal', 8: 'Bilateral Independent Frontal', 9: 'Right Other', 10: 'Left Other',
          11: 'Right Occipital Cortex', 12: 'Left Occipital Cortex', 13: 'Bilateral Occipital Cortex', 14: 'Right Insula',
          15: 'Left Insula', 16: 'Independent Bilateral Insula'}

    return Dx[diagnosticCode]


