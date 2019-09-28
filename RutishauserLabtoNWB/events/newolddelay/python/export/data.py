# ---------------------------------------------------------------------------------------------------------------------
#         Rutishauser Lab, Cedars-Sinai Medical Center/Caltech, 2019.  http://www.rutishauserlab.org/
# ----------------------------------------------------------------------------------------------------------------------
#  Overview:
#     This file (data.py) defines the methods for extracting data from the .mat files in the new/old recognition
#     dataset.
#
#

#
#
# ----------------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------


import os
import numpy as np
import pandas as pd
from scipy.io import loadmat
import RutishauserLabtoNWB.events.newolddelay.python.export.cell as cell
import RutishauserLabtoNWB.events.newolddelay.python.export.trial as trial
import configparser


# ----------------------------------------------------------------------------------------------------------------------

class NOData:

    def __init__(self, datapath, path_to_ini):
        self._path = os.path.join(datapath)
        self._sessions, self._session_nrs = self._define_session(path_to_ini)
        self._markers = self._define_event_markers()

    @property
    def path(self):
        return self._path

    @property
    def sessions(self):
        return self._sessions

    @property
    def session_nrs(self):
        return self._session_nrs

    @property
    def markers(self):
        return self._markers


    def _construct_data_path(self, session_nr, target_folder):

        ''' *****************************************************************************************
            Purpose:
                A method used to construct paths to desired data.

            Input(s):
                session_nr (str): The session ID (e.g., P9HMH_032306)
                target_folder (str): The target folder to create the desired path (e.g., events)

            Returns:
                path (str) -- the path to the desired folder
            ******************************************************************************************'''

        session_name = self.sessions[session_nr]['session']
        task = self.sessions[session_nr]['task_descr']

        path = os.path.join(self.path, 'Data', target_folder, session_name, task)
        return path

    def _extract_event_periods(self, events):

        ''' *********************************************************************************************
            Purpose:
                A method to extract the events from the trial information from the events data.

            Input(s):
                events (pandas.core.frame.DataFrame): The events information for each trial.

            Returns:
                recog_events_time_points (dict): A dictionary of time points for the trial markers.

            *******************************************************************************'''


        # if experiment_type == 'recog':
        stimulus_on_events = events.loc[events[1] == self._markers['stimulus_on']]
        stimulus_off_events = events.loc[events[1] == self._markers['stimulus_off']]
        question_on_events = events.loc[events[1] == self._markers['delay1_off']]
        trial_end_events = events.loc[events[1] == self._markers['delay2_off']]

        # if (stimulus_on_events.shape[0] != 100) | (stimulus_off_events.shape[0] != 100) | \
        # (question_on_events.shape[0] != 100) | (trial_end_events.shape[0] != 100):
        # print('Somethings wrong with the event data, each event should have 100 trials.')

        recog_events_time_points = {'stimulus_on': np.asarray(stimulus_on_events[0]),
                                    'stimulus_off': np.asarray(stimulus_off_events[0]),
                                    'question_on': np.asarray(question_on_events[0]),
                                    'trial_end': np.asarray(trial_end_events[0])}
        # TODO experiment_type = 'learn'

        return recog_events_time_points

    def _get_event_data(self, session_nr, experiment_type='recog'):

        ''' ******************************************************************************
            Purpose:
                Load event data from the raw data set with desired experiment ID

            Input(s):
                session_nr (int): The session ID (e.g., 5)

            Returns:
                events (pandas.core.frame.DataFrame): The events file with the trial information.

        *********************************************************************************** '''


        session_name = self.sessions[session_nr]['session']
        experiment_id_recog = self.sessions[session_nr]['experiment_id_recog']
        experiment_id_learn = self.sessions[session_nr]['experiment_id_learn']
        event_path = os.path.join(self._construct_data_path(session_nr, 'events'), 'eventsRaw.mat')

        events = pd.DataFrame(loadmat(event_path)['events'])
        if experiment_type == 'recog':
            events = events.loc[events[2] == experiment_id_recog]
        elif experiment_type == 'learn':
            events = events.loc[events[2] == experiment_id_learn]
        elif experiment_type == 'All':
            return events
        else:
            raise ValueError('please enter a correct option for experiment ID, now return the entire matrix')
        return events

    def _get_trials_data(self, session_nr, raw_spike_timestamps, path_to_data):

        '''
            Purpose:
                Load event data from the raw data set with desired experiment ID

            Input(s):
                session_nr (int): The session ID (e.g., 5)

            Returns:
                events (pandas.core.frame.DataFrame): The events file with the trial information.



        :param session_nr:
        :param raw_spike_timestamps:
        :return:

        This method use the original experiment stimuli data set to extract the order and categories of the stimuli
        shown to each subjects. The label of the stimulus for the new old recognition task is also obtained using
        this method.
        :param session_nr: session number
        :param raw_spike_timestamps: raw_spike_timestamps from cell
        :return: a list of all trial objects
        '''

        # Get data from variant stimuli data set
        block_id_recog = self.sessions[session_nr]['block_id_recog']
        block_id_learn = self.sessions[session_nr]['block_id_learn']
        variant = self.sessions[session_nr]['variant']
        filename = ''
        if variant == 1:
            filename = 'NewOldDelay_v3.mat'
            filename2 = 'newOldDelayStimuli.mat'
        elif variant == 2:
            filename = 'NewOldDelay2_v3.mat'
            filename2 = 'newOldDelayStimuli2.mat'
        elif variant == 3:
            filename = 'NewOldDelay3_v3.mat'
            filename2 = 'newOldDelayStimuli3.mat'

        path_to_labels = os.path.join(path_to_data, 'Code', 'dataRelease', 'stimFiles', filename)
        experiment_stimuli = loadmat(path_to_labels)['experimentStimuli']
        stimuli_recog_list = experiment_stimuli[0, block_id_recog - 1][3]
        new_old_recog_list = experiment_stimuli[0, block_id_recog - 1][4]
        stimuli_learn_list = experiment_stimuli[0, block_id_learn - 1][2]

        path_to_categories = os.path.join(path_to_data, 'Code', 'dataRelease', 'stimFiles', filename2)
        category_mat = loadmat(path_to_categories)
        category_names = category_mat['categories']
        category_mapping = pd.DataFrame(category_mat['categoryMapping']).set_index(0)
        file_mapping = category_mat['fileMapping']

        # Get events and raw cell data

        events_recog = self._get_event_data(session_nr, experiment_type='recog')
        recog_events_time_points = self._extract_event_periods(events_recog)

        events_learn = self._get_event_data(session_nr, experiment_type='learn')
        learn_events_time_points = self._extract_event_periods(events_learn)

        # Get recog response from log file
        experiment_id_recog = self.sessions[session_nr]['experiment_id_recog']
        log_file_path = os.path.join(self._construct_data_path(session_nr, 'events'), 'newold'+str(experiment_id_recog)+'.txt')
        log_file = pd.read_csv(log_file_path, sep=';', header=None)
        log_events = np.asarray(log_file[1])
        recog_responses = log_events[(log_events >= 31)*(log_events <= 36)] - 30

        # Get learn response from log file
        experiment_id_learn = self.sessions[session_nr]['experiment_id_learn']
        log_file_path = os.path.join(self._construct_data_path(session_nr, 'events'), 'newold'+str(experiment_id_learn)+'.txt')
        log_file = pd.read_csv(log_file_path, sep=';', header=None)
        log_events = np.asarray(log_file[1])
        learn_responses = log_events[(log_events >= 20) * (log_events <= 21)] - 20

        # Create the trial list
        trials = []
        for i in range(0, 100):

            # Processing the recog phase

            baseline_offset = 1000000
            trial_start = recog_events_time_points['stimulus_on'][i] - baseline_offset
            trial_end = recog_events_time_points['trial_end'][i]
            trial_duration = trial_end - trial_start

            trial_timestamps_recog = raw_spike_timestamps[(raw_spike_timestamps > trial_start) *
                                     (raw_spike_timestamps <= trial_end)] - trial_start

            stimuli_recog_id = stimuli_recog_list[0][i]
            category_recog = category_mapping.loc[stimuli_recog_id, 1]

            category_name_recog = category_names[0, category_recog - 1][0]
            file_path_recog = file_mapping[0][stimuli_recog_id - 1][0].replace('C:\code\images\\', '')

            new_old_recog = new_old_recog_list[0][i]
            response_recog = recog_responses[i]

            # Processing the learning phase
            if len(learn_events_time_points['stimulus_on']) > i:
                trial_start = learn_events_time_points['stimulus_on'][i] - baseline_offset
                trial_end = learn_events_time_points['trial_end'][i]
                trial_duration = trial_end - trial_start

                trial_timestamps_learn = raw_spike_timestamps[(raw_spike_timestamps > trial_start) *
                                         (raw_spike_timestamps <= trial_end)] - trial_start
                stimuli_learn_id = stimuli_learn_list[0][i]
                file_path_learn = file_mapping[0][stimuli_learn_id - 1][0].replace('C:\code\images\\', '')

                category_learn = category_mapping.loc[stimuli_learn_id, 1]

                category_name_learn = category_names[0, category_learn - 1][0]
                response_learn = learn_responses[i]
            else:
                category_learn = 'NA'
                category_name_learn = 'NA'
                response_learn = 'NA'
                file_path_learn = 'NA'
                trial_timestamps_learn = 'NA'

            # Creating this trial object
            trial1 = trial.Trial(category_recog, category_name_recog, new_old_recog, response_recog, category_learn,
                          category_name_learn, response_learn, file_path_recog, file_path_learn, stimuli_recog_id,
                          trial_timestamps_recog, trial_timestamps_learn)
            trials.append(trial1)

        return trials


    def _define_session(self, path_to_ini):

        ''' ******************************************************************************
             Purpose:
                 Load the meta-data from ini file, which defines all the sessions.

             Input(s):
                  path_to_ini (str): The path to the .INI configuration file

             Returns:
                 sessions (dict): Meta-data of all the sessions
                 sessions_nrs (list): NOID of all the sessions


             *********************************************************************************** '''

        #  Check config file path
        filename = path_to_ini
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

        # Append Meta-data to sessions
        sessions = {}
        session_nrs = []

        #  Read Meta-data from INI file.
        i = 1
        for section in config.sections():

                session_id = int(section)  # The New/Old ID for the session
                session_nrs.append(session_id)
                # Get the session ID
                for value in config[section]:
                    if value.lower() == 'nosessions.age':
                        age = int(config[section][value])
                    if value.lower() == 'nosessions.diagnosiscode':
                        diagnosis_code = int(config[section][value])
                    if value.lower() == 'nosessions.sex':
                        sex = config[section][value].strip("'")
                    if value.lower() == 'nosessions.id':
                        ID = config[section][value].strip("'")
                    if value.lower() == 'nosessions.session':
                        pt_session = config[section][value].strip("'")
                    if value.lower() == 'nosessions.date':
                        unformattedDate = config[section][value].strip("'")
                    if value.lower() == 'nosessions.session':
                        session = config[section][value].strip("'")
                    if value.lower() == 'nosessions.sessionid':
                        sessionID = config[section][value].strip("'")
                    if value.lower() == 'nosessions.experimentidlearn':
                        experiment_id_learn = int(config[section][value])
                    if value.lower() == 'nosessions.experimentidrecog':
                        experiment_id_recog = int(config[section][value])
                    if value.lower() == 'nosessions.taskdescr':
                        task_descr = config[section][value].strip("'")
                    if value.lower() == 'nosessions.variant':
                        variant = int(config[section][value].strip("'"))
                    if value.lower() == 'nosessions.blockidlearn':
                        block_id_learn = int(config[section][value])
                    if value.lower() == 'nosessions.blockidrecog':
                        block_id_recog = int(config[section][value].strip("'"))
                    if value.lower() == 'nosessions.patient_nb':
                        patient_nb = int(config[section][value])
                    if value.lower() == 'nosessions.filename':
                        filename = config[section][value].strip("'")

                patient_session = i

                sessions[int(section)] = self._make_sess_dict(session, session_id, experiment_id_learn, experiment_id_recog,
                                                            task_descr, variant, block_id_learn, block_id_recog, patient_nb,
                                                            patient_session, diagnosis_code, filename)
                i = i + 1
        return sessions, session_nrs


    def ls_cells(self, session_nr):
        """
        The ls_cells function list all the available cells for a particular session number
        input:
            session_nr = the session number in the dictionary keys
        output:
            cell_list = a list of tuples (channel_nr, cluster_id)
        """
        brain_area_file_path = self._construct_brain_area_path(session_nr)

        brain_area = loadmat(brain_area_file_path)['brainArea']
        cell_list = []
        for i in range(0, brain_area.shape[0]):
            if (brain_area[i][0] != 0) & (brain_area[i][1] != 0):
                if (brain_area[i][3] == 1) | (brain_area[i][3] == 2) | (brain_area[i][3] == 3) | (brain_area[i][3] == 4) | (brain_area[i][3] == 13) | (brain_area[i][3] == 18):
                    cell_list.append((brain_area[i][0], brain_area[i][1]))
        return cell_list

    def pop_cell(self, session_nr, channelnr_clusterid, path_to_data):
        """
        This method pops a particular cell to the user
        input:
            session_nr = the session number that we would like to use
            channelnr_clusterid = the tuple contains both the channel id and the cluster id to select the
                                    desired cell
        output:
            cell = a cell object
        """
        session_name = self.sessions[session_nr]['session']
        brain_area_file_path = self._construct_brain_area_path(session_nr)
        brain_area = loadmat(brain_area_file_path)['brainArea']
        df_brain_area = pd.DataFrame(brain_area)

        brain_area_cell = df_brain_area.loc[
            (df_brain_area[0] == channelnr_clusterid[0]) & (df_brain_area[1] == channelnr_clusterid[1])]

        cell_path = os.path.join(self._construct_data_path(session_nr, 'sorted'),
                                 'A' + str(channelnr_clusterid[0]) + '_cells.mat')
        if os.path.isfile(cell_path):
            raw_spike_timestamps = self._load_cell_data(cell_path, channelnr_clusterid[1])
            trials = self._get_trials_data(session_nr, raw_spike_timestamps, path_to_data)
            cell1 = cell.Cell(cell_path, session_nr, session_name, *np.asarray(brain_area_cell), raw_spike_timestamps, trials)
        else:
            print('source file does not exist, return empty cell.')
            cell1 = None
        return cell1


    def _construct_brain_area_path(self, session_nr):
        path = os.path.join(self._construct_data_path(session_nr, 'events'), 'brainAreaNEW.mat')
        if os.path.isfile(path):
            brain_area_file_path = path
        else:
            brain_area_file_path = os.path.join(self._construct_data_path(session_nr, 'events'), 'brainArea.mat')
        return brain_area_file_path

    # Static helper methods
    @staticmethod
    def _make_sess_dict(session, session_id, experiment_id_learn, experiment_id_recog,
                        task_descr, variant, block_id_learn, block_id_recog, patient_nb,
                        patient_session, diagnosis_code, filename):
        """
        :param session: The session name
        :param session_id: The session id
        :param experiment_id_learn: The experiment id that is for the learning task
        :param experiment_id_recog: The experiment id that is for recognition task
        :param task_descr:
        :param variant: The set of images used for the experiment
        :param block_id_learn: The block id used to index the labels for learning
        :param block_id_recog: The block id used to index the labels for recognition
        :param patient_nb: The patient id
        :param patient_session: The session where the patient is at
        :param diagnosis_code: The code that shows whether a patient has epilepsy or not
        :param filename: The exported filename
        :return: A session dictionary that contains all the above session information
        """
        session = {'session': session,
                   'session_id': session_id,
                   'experiment_id_learn': experiment_id_learn,
                   'experiment_id_recog': experiment_id_recog,
                   'task_descr': task_descr,
                   'variant': variant,
                   'block_id_learn': block_id_learn,
                   'block_id_recog': block_id_recog,
                   'patient_nb': patient_nb,
                   'patient_session': patient_session,
                   'diagnosis_code': diagnosis_code,
                   'filename': filename
                   }

        return session

    @staticmethod
    def _define_event_markers():
        """
        This static method is used to define the useful markers to index the event data.
        :return: marker dictionary
        """
        markers = {'stimulus_on': 1,
                   'stimulus_off': 2,
                   'delay1_off': 3,
                   'delay2_off': 6,
                   'response_1': 31,
                   'response_2': 32,
                   'response_3': 33,
                   'response_4': 34,
                   'response_5': 35,
                   'response_6': 36,
                   'response_learning_animal': 20,
                   'response_learning_non_animal': 21,
                   'experiment_on': 55,
                   'experiment_off': 66}
        return markers

    @staticmethod
    def _load_cell_data(cell_path, cluster_id):
        """
        load the raw cell data and capture the spike train timestamps
        """
        cell_data = loadmat(cell_path)
        channel_raw_spike_timestamps = pd.DataFrame(cell_data['spikes'])
        cell_raw_spike_timestamps = np.asarray(
            channel_raw_spike_timestamps.loc[channel_raw_spike_timestamps[0] == cluster_id, 2])
        return cell_raw_spike_timestamps
