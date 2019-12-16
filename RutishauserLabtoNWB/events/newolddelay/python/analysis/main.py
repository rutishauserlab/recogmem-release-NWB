'''Main file to plot behavior and VS/MS Neurons'''


import RutishauserLabtoNWB.events.newolddelay.python.analysis.behavior_all as behavior_all
import RutishauserLabtoNWB.events.newolddelay.python.analysis.behavior as behavior
import RutishauserLabtoNWB.events.newolddelay.python.analysis.single_neuron as single_neuron
import RutishauserLabtoNWB.events.newolddelay.python.analysis.helper as helper
import warnings


def NO2NWB_analysis(NWBFilePath, list_of_patients_behavior, list_of_patients_neurons):

    '''Section 1 -- NWB file input '''
    #Specify data directory (i.e., where NWB files are located)
    #NWBFilePath = 'V:/LabUsers/chandravadian/NWB Data/p'


    '''Section 2 - Behavioral Analysis '''
    # Specify Patient
    #list_of_patients = [5, 6]
    #list_of_patients = 'all'


    # =============================================================================
    # ============== Plot the behavioral graphs =================================
    #Choose the patient session based on the section header in the 'defineNOsession.ini'


    dataDirectory = NWBFilePath

    if list_of_patients_behavior == 'all': # Plot all on one
        # Plot all sessions on a single plot
        behavior_all.plot_behavioral_graphs(NWBFilePath)

    else: # Plot specified session(s)

        if len(list_of_patients_behavior) > 1: # only works if at least two sessions are analyzed

            session_files = []
            for session in list_of_patients_behavior:
                # Get the nwb files from .INI
                session_file = helper.getpatientfile_fromINIfile(session, dataDirectory)
                session_files.append(session_file)
            # Plot Behavior
            behavior.plot_behavioral_graphs(session_files)
        else:
            warnings.warn('To plot behavior, more than two sessions need to be added in list_of_patients')


    '''Section 3 -- Single Neuron Analysis'''
    # =================================================================================
    # =============== Plot the single neuron analysis =================================


    # Specify the List of Patients to Plot
    #list_of_patients_neurons = [6]


    for session in list_of_patients_neurons:
        session_file = helper.getpatientfile_fromINIfile(session, dataDirectory) # Session file = .nwb file

        neurons = []
        # Get neurons from nwbfile
        try:
            nwbfile = helper.read(session_file)
        except ValueError as e:
            print('Problem opening the file: ' + str(e))
            # logging.warning('Error opening file: ' + session_file)
            continue
        try:
            temp = single_neuron.extract_neuron_data_from_nwb(nwbfile)
        except IndexError as e:
            print("Somehow catch this index error: " + str(e))
            continue
        neurons = neurons + temp

        # Find visually selective (VS) neurons and memory selective (MS) neurons
        vs_neurons = []
        ms_neurons = []

        for neuron in neurons:
            print('Processing..: ', str(neuron.session_id) + ' ', str(neuron.channel_id),' ', str(neuron.neuron_id))
            if neuron.vs_test() < 0.05:
                vs_neurons.append(neuron)
            if neuron.ms_test(1000) < 0.05:
                ms_neurons.append(neuron)

        # Get some Data about VS & MS cells
        print('There are {} VS cell(s) in this session({}): {}'.format(len(vs_neurons), session ,session_file))
        print('There are {} MS cell(s) in this session({}): {}'.format(len(ms_neurons), session ,session_file))


        # Plot the raster/psth for ALL VS neurons and MS neurons in the identified session
        for i in range(0, len(vs_neurons)):
            vs_neurons[i].raster_psth(cell_type='visual')

        for i in range(0, len(ms_neurons)):
            ms_neurons[i].raster_psth(cell_type='memory')