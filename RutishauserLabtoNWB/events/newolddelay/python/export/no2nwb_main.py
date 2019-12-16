# ---------------------------------------------------------------------------------------------------------------------
#         Rutishauser Lab, Cedars-Sinai Medical Center/Caltech, 2019.  http://www.rutishauserlab.org/
# ----------------------------------------------------------------------------------------------------------------------
#  Overview:
#     This is the main file (no2nwb_main.py) that exports human single-unit Medial Temporal Lobe
#     data acquired during a new/old recognition task into the NWB format (Neurodata Without Borders).
#
#
#   This code is part of the data, code, and description released as part of our 2019 data release:
#   TODO: (Add Repository).
#
#  The two papers that describe this data are:
#
#  Rutishauser, U., S. Ye, M. Koroma, O. Tudusciuc, I.B. Ross, J.M. Chung, and A.N. Mamelak.
#  Representation of retrieval confidence by single neurons in the human medial temporal lobe.
#  Nature Neuroscience, 2015. 18(7): p. 1041-50.
#
#  Faraut, M.C.M., Carlson, A., Sullivan, S., Tudusciuc, O., Ross, I., Reed, C.M., Chung, J.M., Mamelak, A.N.,
#  Rutishauser, U. Dataset of human medial temporal lobe single neuron activity during declarative memory encoding
#  and recognition. Scientific Data, (2017).
#
#  Feel free to use this code and data for your own purposes. If you publish work based on this data/code, please cite
#  our data descriptor.
#
# ----------------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------


import os.path
import RutishauserLabtoNWB.events.newolddelay.python.export.no2nwb as no2nwb
import RutishauserLabtoNWB.events.newolddelay.python.export.data as data
from pynwb import NWBHDF5IO
import numpy as np
import logging



def NO2NWB_export(path_to_data):

    ## ========== User Inputs Here ========================================================================================
    #path_to_data = 'C:\\Users\\chandravadn1\\Desktop\\code\data\\Faraut et al 2018'  # Path to Native Data
    ## =====================================================================================================================


    #  Set the Path to save the NWB files
    pathToNWBfiles = input('Where do you want to save NWB files to (no need to put quotes): ')
    while (os.path.exists(pathToNWBfiles)) < 1:
        print('Sorry, this file [{}] does not exist, try again'.format(pathToNWBfiles))
        pathToNWBfiles = input('Where do you want to save NWB files to (no need to put quotes): ')

    # Get .ini file path
    subjects_ini = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(no2nwb.__file__))),
                                    'defineNOsessions_release.ini')
    if not os.path.exists(subjects_ini):
        print('This file does not exist: {}'.format(subjects_ini))


    # Create the NWB file and extract data from the original data format
    NOdata = data.NOData(path_to_data, subjects_ini)


    for session_nr in NOdata.sessions.keys():

        nwbfile = no2nwb.no2nwb(NOdata, session_nr, subjects_ini, path_to_data)

        len_new_old_labels = len(np.asarray(nwbfile.trials['new_old_labels_recog']))
        wrong_sessions = []
        print('The length of the new old label: {}'.format(len_new_old_labels))
        if (len_new_old_labels != 200) & (len_new_old_labels != 150):
            print('Session ' + str(session_nr))
            wrong_sessions.append(session_nr)
            logging.warning('The length of the label data is not either 200 or 150: ' + 'Session ' + str(session_nr))

        # Export and write the nwbfile
        session_name = NOdata.sessions[session_nr]['filename']

        # Check File Outputs
        outputFilePath = os.path.join(pathToNWBfiles, session_name)

        io = NWBHDF5IO(outputFilePath, mode='w')
        io.write(nwbfile, cache_spec = False)
        io.close()
        print('Successfully written this file: {}'.format(outputFilePath))
