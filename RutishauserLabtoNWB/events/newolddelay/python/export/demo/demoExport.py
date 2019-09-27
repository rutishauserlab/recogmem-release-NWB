import urllib.request
import zipfile
import os.path
#from . import no2nwb, data
import no2nwb
import data
import pandas as pd
from pynwb import NWBHDF5IO
import numpy as np
import no2nwb_demo

import logging

logging.basicConfig(filename='strangefiles.log')


# Download the NO dataset from the website
print(os.path.exists('./RecogMemory_MTL_release_v2'))
if not os.path.exists('./RecogMemory_MTL_release_v2'):
    print(1)
    os.path.isfile('./RecogMemory_MTL_release_v2.zip')

    urllib.request.urlretrieve('https://datadryad.org/bitstream/handle/10255/dryad.163179/RecogMemory_MTL_release_v2.zip', \
                               'RecogMemory_MTL_release_v2.zip')

    zip_ref = zipfile.ZipFile('./RecogMemory_MTL_release_v2.zip', 'r')
    zip_ref.extractall('./RecogMemory_MTL_release_v2')
    zip_ref.close()

    os.remove('./RecogMemory_MTL_release_v2.zip')

#Get Path to NWB files
pathToNWBfiles = input('Where do you want to save NWB files to (no need to put quotes): ')
while (os.path.exists(pathToNWBfiles))  < 1:
    print('Sorry, this file [{}] does not exist, try again'.format(pathToNWBfiles))
    pathToNWBfiles = input('Where do you want to save NWB files to (no need to put quotes): ')



# Set data path
path_to_data = 'C:\\Users\\chandravadn1\\Desktop\\code\\data\\Faraut et al 2018\\'



# Read in subject data
subjects = pd.read_csv('subjects.csv')
subjects_ini = 'C:\\svnwork\\nwbsharing\\events\\newolddelay\\defineNOsessions_release.ini'  #  Set the Path to ~.ini

# Create the NWB file and extract data from the original data format
NOdata = data.NOData(path_to_data)

session_nr = 122
nwbfile = no2nwb.no2nwb(NOdata, session_nr, subjects_ini, path_to_data)
len_new_old_labels = len(np.asarray(nwbfile.trials['new_old_labels_recog']))
session_name = NOdata.sessions[session_nr]['session']

io = NWBHDF5IO(pathToNWBfiles + '/' + session_name + '.nwb', mode='w')
io.write(nwbfile)
io.close()


