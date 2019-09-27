import no2nwb
import data
from pynwb import NWBHDF5IO


# Set Path to Native Data
path_to_data = 'C:\\Users\\chandravadn1\\Desktop\\code\\data\\Faraut et al 2018\\'
#Read in Subject Meta-Data
subjects_ini = 'C:\\svnwork\\nwbsharing\\events\\newolddelay\\defineNOsessions_release.ini'  #  Set the Path to ~.ini

# Create the NWB file and extract data from the original data format
NOdata = data.NOData(path_to_data)

#Set the Session to Export
session_nr = 144
nwbfile = no2nwb.no2nwb(NOdata, session_nr, subjects_ini, path_to_data)
session_name = NOdata.sessions[session_nr]['session']

io = NWBHDF5IO(session_name + '.nwb', mode='w')
io.write(nwbfile)
io.close()