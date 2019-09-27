import numpy as np
from pathlib import Path
import os
import sys
from pynwb import NWBHDF5IO

# Input Path Here
nwbBasePath = Path('V:/LabUsers/chandravadian/NWB Data/python/')
session = 'P53CS_110217.nwb'
nwbFilePath = str(nwbBasePath /  session)

# =====================================================
# =====================================================
if not os.path.exists(nwbFilePath):
    print('This file does not exist: {}'.format(nwbFilePath))
    sys.exit(-1)

# Read NWB file
io = NWBHDF5IO(nwbFilePath, mode='r')
nwbfile = io.read()


