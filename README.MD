# A NWB-based Dataset and Processing Pipeline of Human Single-Neuron Activity During a Declarative Memory Task 

[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![Generic badge](https://img.shields.io/badge/release-1.0.0-green.svg)](https://github.com/rutishauserlab/recogmem-release-NWB/releases/)
[![Generic badge](https://img.shields.io/badge/DOI-10.17605/OSF.IO/HV7JA-orange.svg)](https://osf.io/hv7ja/)

## Introduction 

This repository contains tools/methods to export human single neuron data into the [Neurodata Without Borders](https://www.nwb.org/) Format, and analyze such data in NWB. This dataset is entirely in the NWB Format, and the export and analysis scripts are in both Python and MATLAB. 

This code accompanies the paper: Chandravadia, N., Liang, D., Schjetnan, A. G. P., Carlson, A., Faraut, M., Chung, J. M., Reed, C. M., Dichter, B., Maoz, U., Kalia, S. K., Valiante, T. A., Mamelak, A. N. & Rutishauser, U. A NWB-based dataset and processing pipeline of human single-neuron activity during a declarative memory task. Scientific Data 7, 78, (2020). [Link to paper](https://www.nature.com/articles/s41597-020-0415-9)

Abstract of the paper: 

>A challenge for data sharing in systems neuroscience is the multitude of different data formats used. Neurodata Without Borders: Neurophysiology 2.0 (NWB:N) has emerged as a standardized data format for the storage of cellular-level data together with meta-data, stimulus information, and behavior. A key next step to facilitate NWB:N adoption is to provide easy to use processing pipelines to import/export data from/to NWB:N. Here, we present a NWB-formatted dataset of 1863 single neurons recorded from the medial temporal lobes of 59 human subjects undergoing intracranial monitoring while they performed a recognition memory task. We provide code to analyze and export/import stimuli, behavior, and electrophysiological recordings to/from NWB in both MATLAB and Python. The data files are NWB:N compliant, which affords interoperability between programming languages and operating systems. This combined data and code release is a case study for how to utilize NWB:N for human single-neuron recordings and enables easy re-use of this hard-to-obtain data for both teaching and research on the mechanisms of human memory.

<p align="center">
  <img width="460" height="410" src="https://raw.githubusercontent.com/rutishauserlab/recogmem-release-NWB/master/RutishauserLabtoNWB/assets/BrainAreaLocations.png">
</p>

<!--- Add Data Descriptor Link here ---> 
A previous version of this dataset (which contains less data than this dataset and is not in NWB) was [released previously](https://datadryad.org/resource/doi:10.5061/dryad.46st5) and is described in this [data descriptor (Faraut et al. 2018)](https://www.nature.com/articles/sdata201810).

## Installation (Code)

For python, the code within this repository can be installed via `pip`:

`pip install RutishauserLabtoNWB` or `pip3 install RutishauserLabtoNWB`

For matlab or python, this repository can be downloaded via:

`git clone https://github.com/rutishauserlab/recogmem-release-NWB.git`


## Installation (Data)

There are two different data downloads:
1) To export the data from our internal proprietary format to NWB, you first need to download the [raw data](https://osf.io/cd6qp/). 
2) If you only need the dataset in NWB (to analyze the data), download the dataset from [here](https://osf.io/pybzc/).

## Installation (pyNWB and matNWB)

### [pyNWB](https://github.com/NeurodataWithoutBorders/pynwb)

pyNWB can be installed via `pip`: 

`pip install pynwb` 

Alternatively, the pyNWB can be downloaded via:

`git clone https://github.com/NeurodataWithoutBorders/pynwb.git
`

*Note: We used pyNWB version 1.1.0* 

### [matNWB](https://github.com/NeurodataWithoutBorders/matnwb)

The matNWB API is provided in the same download as above (RutishauserLab2NWB) -- it can be found under 3rd Party. 

*Note: We used matNWB version 0.2.1*


## Package Dependencies (Python)

Here are a list of Python packages we used, and their respective versions: 

* numpy (1.17.2)
* pandas (0.23.0)
* scipy (1.1.0)
* matplotlib (2.2.2)
* pynwb (1.1.0)
* hdmf (1.2.0)
* seaborn (0.9.0)

Please assure that you're using the above versions of pywnb and hdmf, because newer development versions often break things. Use `pip install pynwb==1.1.0` and  `pip install hdmf==1.2.0` to force installation of these versions.

## Python Export and Analysis


Here, we will detail how to run the Python Export Code, which converts the native data into NWB, and the Single Neuron Analysis based on these NWB files. All the python code is found here: [recogmem-release-NWB/RutishauserLabtoNWB/events/newolddelay/python/](https://github.com/rutishauserlab/recogmem-release-NWB/tree/master/RutishauserLabtoNWB/events/newolddelay/python)


### Python Export

This code shows how to export from our internal dataformat to NWB. Note that if you only want to use the provided NWB files for analysis in python, you do not need to re-export the data. Instead, go directly to the analysis step below. 
The main export script is `no2nwb_main.py`. Modify the following parameters:


* [pathtoNativeData](https://osf.io/cd6qp/): the path to Native Data. 
*Note: The Native Data must be downloaded via the provided external link, and the path to data must be given as shown below.*


```python 
import RutishauserLabtoNWB as RLab


pathTONativeData = 'C:\\Users\\chandravadn1\\Desktop\\code\\dataNative\\'

RLab.NO2NWB_export(pathTONativeData)
```

Once you have changed the the above parameters, run `NO2NWB_export`. This will begin the export of the native data into NWB:N. 


*Note: Once run, `NO2NWB_export` will ask for an export directory. Supply a directory to save the NWB files.*



### Python Analysis (Single Neuron Analysis) 

This code shows how to import the NWB-formatted data. The main analysis script is `main.py`. Modify the following parameters:

* **NWBFilePath**: The path to the exported NWB files. 
* **list_of_patients_behavior**: This signifies the NOID (Patient Identifier). See defineNOsessions.ini to see the NOID for all patients. Note: You can list more than one NOID. For example, ```list_of_patients = [5, 6, 132]```. You can also input ```list_of_patients = 'all'``` to examine the results for all patients. 
* **list_of_patients_neurons**: This signifies the NOID (Patient Identifier). See defineNOsessions.ini to see the NOID for all patients. Note: You can list more than one NOID. For example, ```list_of_patients = [5, 6, 132]```

```python 
import RutishauserLabtoNWB as RLab

NWBFilePath = 'V:\\LabUsers\\chandravadian\\NWB Data\\python'
list_of_patients_behavior = [5, 6]  # List of sessions to summarize behavior. Set to [] to skip
list_of_patients_neurons = [132]    # List of sessions to analyze neural data for. Set to [] to skip

RLab.NO2NWB_analysis(NWBFilePath,list_of_patients_behavior, list_of_patients_neurons)

```

Once you have changed the the above parameters, run `NO2NWB_analysis`. This will begin the analysis of the data in the NWB:N format. Note that you have to close the plots that open up for the analysis to continue, the code blocks after opening a figure.


<!--- Raster Plot Here (Python) ---> 
<p align="center">
  <img width="460" height="410" src="https://raw.githubusercontent.com/rutishauserlab/recogmem-release-NWB/master/RutishauserLabtoNWB/assets/Python_SingleNeuron.png">
</p> 


<!--- MATLAB ---> 
## MATLAB Export and Analysis


Here, we will detail how to run the MATLAB Export Code, which converts the native data into NWB, and the Single Neuron Analysis based on these NWB files. All the MATLAB code can be found here: [recogmem-release-NWB/RutishauserLabtoNWB/events/newolddelay/matlab/](https://github.com/rutishauserlab/recogmem-release-NWB/tree/master/RutishauserLabtoNWB/events/newolddelay/matlab)



### MATLAB Export

This code shows how to export from our internal dataformat to NWB. Note that if you only want to use the provided NWB files for analysis in Matlab, you do not need to re-export the data. Instead, go directly to the analysis step below. 
This code shows how to import and analyze the NWB-formatted data. The main export script is `exportNO2NWB_main.m`. Within `exportNO2NWB_main.m`, modify the following:

**%% Section 1 -- Set Parameters - modify this section before running this code !**

* [basepath](https://osf.io/cd6qp/): the path to Native Data. 
*Note: The Native Data must be downloaded via the provided external link, and the path to data must be given as shown below.*
* [codePath](https://github.com/rutishauserlab/recogmem-release-NWB/tree/master/RutishauserLabtoNWB): the path to the NWB:N code.  

```matlab 
%Input Base Path to the Native Data
basepath = 'C:\Users\chandravadn1\Desktop\code\dataNative\';

%Add base code path (e.g., 'C:\svnwork\nwbsharing') 
codePath = '\\RutishauserLabtoNWB\\';
```

Once you have changed the the above parameters, run `exportNO2NWB_main.m`. This will begin the export of the native data into NWB:N. 

*Note: Once run, `exportNO2NWB_main.m` will ask for an export directory. Supply a directory to save the NWB files.*

### MATLAB Analysis

The main analysis script is `NWBneural_main.m`. Witin `NWBneural_main.m`, modify the following:

**%% Section 1: Set Parameters - modify this section before running this code !**

* [codePath](https://github.com/rutishauserlab/recogmem-release-NWB/tree/master/RutishauserLabtoNWB): the path to the NWB:N code.
* **basepathData**: The path to the exported NWB files. 
* **exportStimInfo**: Indicates whether or not stimuli will be exported into NWB file (0: no, 1: yes)
* **allSessionsToUse**: This signifies the NOID (Patient Identifier). See defineNOsessions.ini to see the NOID for all patients. Note: You can list more than one NOID. For example, ```list_of_patients = [5, 6, 132]```
* **runAllAvailableSesssions**: Enable to process all available sessions (not just the one(s) specified above). Uses NWB_listOf_allUsable
 
```matlab 
%% Section 1: Set Parameters - modify this section before running this code !

% Point this directory to where the downloaded code is located.
codePath = '\\RutishauserLabtoNWB\\'; 

% Point this directory to where the downloaded NWB data is located.
basepathData = 'V:\LabUsers\chandravadian\NWB Data\'; 

exportStimInfo = 1;   % 0 no, 1 yes.  If turned off, the resulting NWB files do not contain the stimuli shown (images). This reduces the size of the NWB files considerably

runAllAvailableSesssions = 0;
```

Once you have changed the the above parameters, run `NWBneural_main.m`. This will begin the analysis of the data in the NWB:N format. 

<!--- Raster Plot Here (MATLAB) ---> 
<p align="center">
  <img width="460" height="410" src="https://raw.githubusercontent.com/rutishauserlab/recogmem-release-NWB/master/RutishauserLabtoNWB/assets/MATLAB_SingleNeuron.png">
</p> 


## Jupyter Notebook

![Alt Text](https://media.giphy.com/media/igtwCeD01AU0zmPsUN/giphy.gif)


Additionally, we have included two Jupyter Notebooks ([demoAnalysis.ipynb](https://github.com/rutishauserlab/recogmem-release-NWB/blob/master/RutishauserLabtoNWB/events/newolddelay/python/analysis/demo/demoAnalysis.ipynb)
& [plotFigure5.ipynb](https://github.com/rutishauserlab/recogmem-release-NWB/blob/master/RutishauserLabtoNWB/events/newolddelay/python/analysis/demo/plotFigure5.ipynb)) that 
replicate key processes in our pipeline. These notebooks demonstrate how to read from the NWB files, and run
simple analyses based on these files. 



## Contributors
* [Nand Chandravadia](mailto:nand.c@columbia.edu) 
* [Andy Liang](mailto:liang134@mail.chapman.edu) 
* [Ueli Rutishauser](mailto:Ueli.Rutishauser@cshs.org) (Principal Investigator)

Feel free to ask questions and/or join the development discussion. You can post bug reports and feature requests. You are welcome to use/modify the code/data in this repository as you wish -- if you do, please cite our data descriptor: 

* Chandravadia, N., Liang, D., Schjetnan, A. G. P., Carlson, A., Faraut, M., Chung, J. M., Reed, C. M., Dichter, B., Maoz, U., Kalia, S. K., Valiante, T. A., Mamelak, A. N. & Rutishauser, U. A NWB-based dataset and processing pipeline of human single-neuron activity during a declarative memory task. Scientific Data 7, 78, (2020). 

## Funding

Acquisition of this dataset has been supported by the National Institute of Neurological Disorders and Stroke (U01NS103792), the National Science Foundation (1554105), the National Institute of Mental Health (R01MH110831), the McKnight Endowment for Neuroscience, a NARSAD Young Investigator grant from the Brain & Behavior Research Foundation. Preparation of this dataset was made possible by a seed grant from the Kavli Foundation.

## License 

"RutishauserLabtoNWB" Copyright (c) 2019, Rutishauser Lab. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
