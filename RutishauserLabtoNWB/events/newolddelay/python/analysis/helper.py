
from pynwb import NWBHDF5IO
import numpy as np
import math
import re
import os
from scipy.stats import norm
import configparser
import RutishauserLabtoNWB.events.newolddelay.python.export.no2nwb as no2nwb


def get_nwbfile_names(path):
    """
    Get all nwb file paths in the folder
    """
    filenames = []
    for file in os.listdir(path):
        if file.endswith(".nwb"):
            nwbfile = os.path.join(path, file)
            if os.path.exists(nwbfile):
                filenames.append(str(nwbfile))

    return filenames


def read(file_path):
    """
    read in files
    """
    io = NWBHDF5IO(file_path, mode='r')
    nwbfile = io.read()
    return nwbfile


def get_event_data(nwbfile):
    """
    Get event data from the nwbfile
    """
    events = nwbfile.get_acquisition('events')
    experiment_id_list = np.asarray(nwbfile.get_acquisition('experiment_ids').data)
    events_data = np.asarray(events.data)
    events_timestamps = np.asarray(events.timestamps)

    experiment_description = nwbfile.data_collection

    experiment_ids = re.findall(r'\d+', experiment_description)
    experiment_id_learn = int(experiment_ids[0])
    experiment_id_recog = int(experiment_ids[1])

    ind_learn = np.where(experiment_id_list == experiment_id_learn)
    ind_recog = np.where(experiment_id_list == experiment_id_recog)

    events_learn = events_data[ind_learn].astype(float)
    timestamps_learn = events_timestamps[ind_learn]

    events_recog = events_data[ind_recog].astype(float)
    timestamps_recog = events_timestamps[ind_recog]

    return events_learn, timestamps_learn, events_recog, timestamps_recog


def extract_recog_responses(nwbfile):
    """
    Extract the recognition responses
    """
    events_learn, timestamps_learn, events_recog, timestamps_recog = get_event_data(nwbfile)
    response_recog_ind = np.where((events_recog >= 30) & (events_recog <= 36))
    response_recog = events_recog[response_recog_ind] - 30
    return response_recog


def extract_new_old_label(nwbfile):
    """
    Extracting the new old ground truths from the nwbfile.
    """
    labels = np.asarray(nwbfile.trials['new_old_labels_recog'].data)


    if not (labels.dtype == 'O'): #check Matlab data type
        new_old_labels = np.delete(labels, np.where(labels == 10)).astype(int)
    else: #Python
        new_old_labels = np.delete(labels, np.where(labels == 'NA')).astype(int)

    return new_old_labels


def count_response(filenames):
    """
    Count the responses
    """
    response_1_old = []
    response_2_old = []
    response_3_old = []
    response_4_old = []
    response_5_old = []
    response_6_old = []

    response_1_new = []
    response_2_new = []
    response_3_new = []
    response_4_new = []
    response_5_new = []
    response_6_new = []
    for file in filenames:
        nwb_file = read(file)
        recog_response = extract_recog_responses(nwb_file)
        ground_truth = extract_new_old_label(nwb_file)
        recog_response_old = recog_response[ground_truth == 1]

        response_1_old.append(np.sum(recog_response_old == 1) / len(recog_response_old))
        response_2_old.append(np.sum(recog_response_old == 2) / len(recog_response_old))
        response_3_old.append(np.sum(recog_response_old == 3) / len(recog_response_old))
        response_4_old.append(np.sum(recog_response_old == 4) / len(recog_response_old))
        response_5_old.append(np.sum(recog_response_old == 5) / len(recog_response_old))
        response_6_old.append(np.sum(recog_response_old == 6) / len(recog_response_old))

        recog_response_new = recog_response[ground_truth == 0]
        response_1_new.append(np.sum(recog_response_new == 1) / len(recog_response_new))
        response_2_new.append(np.sum(recog_response_new == 2) / len(recog_response_new))
        response_3_new.append(np.sum(recog_response_new == 3) / len(recog_response_new))
        response_4_new.append(np.sum(recog_response_new == 4) / len(recog_response_new))
        response_5_new.append(np.sum(recog_response_new == 5) / len(recog_response_new))
        response_6_new.append(np.sum(recog_response_new == 6) / len(recog_response_new))

    response_old = np.asarray([response_1_old, response_2_old, response_3_old, response_4_old,
                               response_5_old, response_6_old])
    response_new = np.asarray([response_1_new, response_2_new, response_3_new, response_4_new,
                               response_5_new, response_6_new])
    return response_old, response_new

def extract_probability_response(filenames):
    """
    :param nwbfile:
    :return:
    """
    response_old, response_new = count_response(filenames)
    response_percentage_old = np.mean(response_old, axis=1)
    std_old = np.std(response_old, axis=1)
    response_percentage_new = np.mean(response_new, axis=1)
    std_new = np.std(response_new, axis=1)
    return response_percentage_old, std_old, response_percentage_new, std_new


def cal_d_prime(typecounters, n_old, n_new):
    """
    calc D' (d) as well as z-transformed hit rate and false positive rate (zH, zF respectively).

    typeCounters is TP/FN/TN/FP, where positive=OLD

    according to Macmillan&Creelman, Eq 1.1, 1.2, 1.5;
    error estimation of d' is: Eq 13.4, 13.5

    """
    H = 0
    F = 0
    if n_old > 0:
        H = typecounters[0]/n_old
    if n_new > 0:
        F = typecounters[3]/n_new

    # % adjust
    # for perfect(1) and 0(all misses)
    # % acc
    # to
    # pp8
    H, F = adjustHF(H, F, n_new, n_old)

    zH = norm.ppf(H)
    zF = norm.ppf(F)

    d = zH - zF

    # % Eq
    # 13.4, pp325

    phi = lambda p: 1/np.sqrt(2*math.pi)*np.exp(-1/2*np.square(norm.ppf(p)))

    # % Eq
    # 13.4, pp325
    Hterm = H * (1 - H) / (n_old * np.square(phi(H)))
    Fterm = F * (1 - F) / (n_new * np.square(phi(F)))

    stdErr = Hterm + Fterm
    se = np.sqrt(stdErr)

    return d, zH, zF, H, F, se


def adjustHF(H, F, n_new, n_old):
    """
    adjust hit/false alarm rate for ceiling effects
    according to Macmillan&Creelman, pp8
    urut/nov06
    """

    if H == 1:
        H = 1 - 1/(2*n_old)
    if F == 1:
        F = 1 - 1/(2*n_new)
    if H == 0:
        H = 1/(2*n_old)
    if F == 0:
        F = 1/(2*n_new)

    return H, F

def cal_cumulative_d(nwbfile):
    """
    calculate cummulative d' values as well as z-transformed hit/false alarm rates. used to construct empirical ROCs constructed using different
    confidence ratings.

    the format of C is described in calcEmpiricalROC.m

    statsAll: each column is a confidence level. each row is d', zH, zF, H, F

    urut/oct06
    """
    typecounter = cal_typecounter(nwbfile)
    n_old = np.sum(typecounter[0, :])
    n_new = np.sum(typecounter[3, :])

    stats_all = []
    for i in range(typecounter.shape[1]):
        temp = np.sum(typecounter[:, 0:i+1], axis=1)
        d1, zH1, zF1, H, F, se = cal_d_prime(temp, n_old, n_new);
        stats_all.append([d1, zH1, zF1, H, F, se])

    return np.asarray(stats_all)


def cal_typecounter(nwbfile):
    """
    calculate the true positives, true negatives, false positives and false negatives
    """
    response_recog = extract_recog_responses(nwbfile)


    labels = np.asarray(nwbfile.trials['new_old_labels_recog'].data)

    if not (labels.dtype == 'O'):  # check Matlab data type
        new_old_labels = np.delete(labels, np.where(labels == 10)).astype(int)
    else:  # Python
        new_old_labels = np.delete(labels, np.where(labels == 'NA')).astype(int)




    typecounter = []

    for i in range(6, 0, -1):
        new_old_labels_selected = new_old_labels[response_recog == i]
        #print(np.sum((response_recog_accumulated == 1) & (new_old_labels_accumulated == 1)))
        nTP = np.sum(new_old_labels_selected == 1)
        nFN = 0
        nTN = 0
        nFP = np.sum(new_old_labels_selected == 0)
        typecounter.append([nTP, nFN, nTN, nFP])

    return np.asarray(typecounter).T


def cal_auc(stats_all):
    """
    area under the curve AUC of an ROC
    Following eq 3.9, pp 64 of Macmillan book.
    partly copied from novelty/ROC/calcAUC.m (thus overlaps)
    TP/FP are expected to be ordered (ascending), but are not automatically resorted as this
    might introduce artifacts in case of non-monotonic ROCs.

    if reverseOrder=1, TP and FP are expected in descending order
    automatically adds the (0,0) and (1,1) point if it does not exist yet
    """
    TP = stats_all[:, 3]
    FP = stats_all[:, 4]

    if (TP[0] != 0) | (FP[0] != 0):
        TP = np.insert(TP, 0, 0)
        FP = np.insert(FP, 0, 0)

    if (TP[len(TP)-1] != 1) | (FP[len(FP)-1] != 1):
        TP = np.insert(TP, len(TP), 1)
        FP = np.insert(FP, len(FP), 1)

    auc = 0
    for i in range(1, len(TP)):
        auc = auc + (FP[i] - FP[i-1]) * TP[i-1]
        auc = auc + 1/2 * (TP[i]-TP[i-1]) * (FP[i]-FP[i-1])

    return auc


def dynamic_split(recog_response, ground_truth):
    """
    Split low/high confidence dynamically
    """
    n_response = len(recog_response)

    rep_counts = np.zeros(6)
    for i in range(1, 7):
        sum_up = np.sum(recog_response == i)
        rep_counts[i-1] = sum_up


    nr_conf1 = rep_counts[0] + rep_counts[5]
    nr_conf2 = rep_counts[1] + rep_counts[4]
    nr_conf3 = rep_counts[2] + rep_counts[3]

    split1 = nr_conf1 - (nr_conf2 + nr_conf3)
    split2 = (nr_conf1 + nr_conf2) - nr_conf3

    split_status = [split1, split2]

    split_mode = np.where(np.abs(split_status) == np.min(np.abs(split_status)))[0][0]+1

    # If there are no 1 and 6 response, use mode 2 to combine 1,2 and 5,6 for high confidence
    if (rep_counts[0] == 0) | (rep_counts[5] == 0):
        split_mode = 2
    if (rep_counts[1] == 0) | (rep_counts[4] == 0):
        split_mode = 1

    if split_mode == 1:
        # 1, (2,3), (4,5), 6
        # TP & FP
        ind_TP_high = np.where((ground_truth == 1) & (recog_response >= 6))
        ind_TP_low = np.where((ground_truth == 1) & (recog_response == 4))
        ind_FP_high = np.where((ground_truth == 0) & (recog_response >= 6))
        ind_FP_low = np.where((ground_truth == 0) & (recog_response == 4))

        # TN & FN
        ind_TN_high = np.where((ground_truth == 0) & (recog_response <= 1))
        ind_TN_low = np.where((ground_truth == 0) & ((recog_response == 3) | (recog_response == 2)))
        ind_FN_high = np.where((ground_truth == 1) & (recog_response <= 1))
        ind_FN_low = np.where((ground_truth == 1) & ((recog_response == 3) | (recog_response == 2)))

    else:
        # (1,2), 3, 4, (5,6)
        # TP & FP
        ind_TP_high = np.where((ground_truth == 1) & (recog_response >= 5))
        ind_TP_low = np.where((ground_truth == 1) & (recog_response == 4))
        ind_FP_high = np.where((ground_truth == 0) & (recog_response >= 5))
        ind_FP_low = np.where((ground_truth == 0) & (recog_response == 4))

        # TN & FN
        ind_TN_high = np.where((ground_truth == 0) & (recog_response <= 2))
        ind_TN_low = np.where((ground_truth == 0) & (recog_response == 3))
        ind_FN_high = np.where((ground_truth == 1) & (recog_response <= 2))
        ind_FN_low = np.where((ground_truth == 1) & (recog_response == 3))

    return split_status, split_mode, ind_TP_high, ind_TP_low, ind_FP_high, ind_FP_low, \
           ind_TN_high, ind_TN_low, ind_FN_high, ind_FN_low, n_response


def correct_incorrect_indexes(recog_response, ground_truth):
    """
    Get the indexes for correct and incorrect responses
    """
    correct_ind = np.where(((recog_response <= 3) & (ground_truth == 0)) | ((recog_response >=4) & (ground_truth == 1)))
    incorrect_ind = np.where(((recog_response <= 3) & (ground_truth == 1)) |
                             ((recog_response >= 4) & (ground_truth == 0)))

    return correct_ind[0], incorrect_ind[0]


def remap_response(recog_response):
    """
    remap the responses to high (1), median (2), and low (3) level
    """
    recog_response[recog_response == 6] = 1
    recog_response[recog_response == 5] = 2
    recog_response[recog_response == 4] = 3

    return recog_response


def check_inclusion(recog_response, auc):
    """
    Check whether to include the session or not for confidence vs correctness
    """
    resp_count = []
    is_included = 1

    if auc < 0.6:
        is_included = 0

    for i in range(1, 7):
        resp_count.append(np.sum(recog_response == i))

    resp_count = np.asarray(resp_count)

    if (np.sum(resp_count[0:3] == 0) > 1) | (np.sum(resp_count[3:6] == 0) > 1):
        is_included = 0

    return is_included


def extract_response_from_nwbfile(nwbfile):
    """
    Extract recognition/learning responses from the nwbfile
    """
    experiment_description = nwbfile.experiment_description
    experiment_ids = np.unique(nwbfile.acquisition['experiment_ids'].data)
    experiment_id_recog = int(experiment_ids[1])
    experiment_id_learn = int(experiment_ids[0])

    events = (np.asarray(nwbfile.get_acquisition('events').data)).astype(float)
    experiments = np.asarray(nwbfile.get_acquisition('experiment_ids').data)

    events_recog = events[((experiments == experiment_id_recog) & ((events >= 30) & (events <= 36)))] - 30
    events_learn = events[((experiments == experiment_id_learn) & ((events >= 20) & (events <= 21)))] - 20

    return events_recog, events_learn

def getpatientfile_fromINIfile(patientID, dataDirectory):

    """ Get the patient file from the INI config file

    Input: patientID (numerical type) from defineNOsessions_release.ini
    header


    Output: file path of session (.nwb)"""

    #initialze the ConfigParser() class
    config = configparser.ConfigParser()

    #Get the path to the configuration file
    subjects_ini = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(no2nwb.__file__))),
                                'defineNOsessions_release.ini')

    filename = subjects_ini
    if not os.path.exists(filename):
        print ('This file does not exist: {}'.format(filename))
        print ("Check filename/and or directory")

    #Read the config file
    try:
        config.read(filename)
        #print ('This file was successfully read: {}\n'.format(filename))
    except:
        print ('Failed to read the config file..')
        print ('Does this file exist: {}'.format(os.path.exists(filename)))


    #Read the headers of the configuration file
    for section in config.sections():

        if section == str(patientID):
            patient_header = section

            #get values for each section header
            for value in config[patient_header]:
                #print (value)
                #print (type(value))
                if value.lower() == 'nosessions.filename':
                    patient_sessionValue = config[patient_header][value].strip("'")

        elif not (str(patientID) in config):
            print ("Invalid patientID: {}".format(patientID))
            print ("Check defineNOsessions_release.ini....")

    #Get Data from Data Directory
    patient_sessionpath=' '
    if not os.path.exists(dataDirectory):
         print('This directory does not exist: {}'.format(dataDirectory))
         print('Please Enter a valid Directory')
    else:
        NWBfiles = os.listdir(str(dataDirectory))

        for NWBfile in NWBfiles:
            if (NWBfile == patient_sessionValue) & (not NWBfile.startswith('.')):
                patient_sessionpath = os.path.join(dataDirectory, NWBfile)


    if not (os.path.exists(patient_sessionpath)):
        print ('This file does not exists: {}'.format(patient_sessionpath))
        print ('Check file and/or directory')


    return str(patient_sessionpath)