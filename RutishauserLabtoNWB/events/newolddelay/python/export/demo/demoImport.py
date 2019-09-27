from pynwb import NWBHDF5IO
import no2nwb
import pandas as pd
import data



pathToNWBfiles = 'C:\\Users\\chandravadn1\\'
path_to_data = 'C:\\Users\\chandravadn1\\Desktop\\code\\data\\Faraut et al 2018\\Data'

session_nr = 1
NOdata = data.NOData(path_to_data)
subjects = pd.read_csv('subjects.csv')
nwbfile = no2nwb.no2nwb(NOdata, session_nr, subjects)
NOdata = data.NOData(path_to_data)

io = NWBHDF5IO(pathToNWBfiles + str(session_nr) + '.nwb', mode='w')
io.write(nwbfile)
io.close()

