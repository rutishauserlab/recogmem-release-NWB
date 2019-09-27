import RutishauserLabtoNWB.events.newolddelay.python.analysis.helper as helper
import scipy.stats as stats
import logging
import matplotlib.pyplot as plt
import numpy as np

def plot_behavioral_graphs(*argv):

    """
    Input: Variable number of NWB sessions in the '~~~.nwb' format

    Output:

    Behavioral analysis, plotting six graphs:
    1. Probability of responses
    2. ROC curves for different sessions
    3. Overall performance
    4. Histogram of AUC
    5. Accuracy over confidence high low
    6. Confidence level over correctness of responses
    """

    #Assign filenames from argument(s)
    for args in argv:
        filenames = args

    n = 0

    # make the subplots
    fig, axs = plt.subplots(nrows=2, ncols=3, sharex=False, sharey=False, figsize=(20, 10))

    # Place holder ready to store separate the new and old response
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

    # Placeholder for overall performance
    all_performances = []

    # Placeholder for aucs
    all_auc = []

    # Placeholder for accuracies for different confidence level
    accuracies_high = []
    accuracies_low = []
    accuracies_all = []

    # Placeholder for mean confidences over correctness
    m_conf_all = []

    for filename in filenames:
        try:
            print('processing file: ',  filename)
            nwbfile = helper.read(str(filename))
        except ValueError as e:
            print('Problem opening the file: ' + str(e))
            logging.warning('Error File: ' + filename + ':' + str(e))
            continue
        except OSError as e:
            print('Problem opening the file:' + str(e))
            logging.warning('Error File ' + filename + ':' + str(e))
            continue

        recog_response = helper.extract_recog_responses(nwbfile)
        ground_truth = helper.extract_new_old_label(nwbfile)

        if len(recog_response) != len(ground_truth):
            print('response length not equal to ground truth, skipped this session: {}'.format(filename))
            continue
        else:
            recog_response_old = recog_response[ground_truth == 1]
            n = n + 1

        # Calculate the percentage of each responses
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

        # Calculate the cumulative d and plot the cumulative ROC curve
        stats_all = helper.cal_cumulative_d(nwbfile)
        x = stats_all[0:5, 4]
        y = stats_all[0:5, 3]
        axs[0, 1].plot(x, y, marker='.', color='grey', alpha=0.5)
        axs[0, 1].set_ylim(0, 1)
        axs[0, 1].set_xlim(0, 1)

        # Get the overall performance
        all_performances.append([stats_all[2, 4], stats_all[2, 3]])

        # Calculate the auc
        auc = helper.cal_auc(stats_all)
        all_auc.append(auc)

        # Check if this session should be included in the accuracies over high low section
        is_included = helper.check_inclusion(recog_response, auc)
        # Calculate the accuracies for high low confidence
        if is_included:
            split_status, split_mode, ind_TP_high, ind_TP_low, ind_FP_high, ind_FP_low, ind_TN_high, \
            ind_TN_low, ind_FN_high, ind_FN_low, n_response = helper.dynamic_split(recog_response, ground_truth)
            nr_TN_high = len(ind_TN_high[0])
            nr_TP_high = len(ind_TP_high[0])
            nr_TN_all = len(ind_TN_high[0]) + len(ind_TN_low[0])
            nr_TN_low = len(ind_TP_high[0]) + len(ind_TP_low[0])
            nr_TP_low = len(ind_TP_low[0])
            nr_TN_low = len(ind_TN_low[0])

            nr_high_response = len(ind_TN_high[0]) + len(ind_TP_high[0]) + len(ind_FN_high[0]) + len(ind_FP_high[0])
            nr_low_response = len(ind_TN_low[0]) + len(ind_TP_low[0]) + len(ind_FN_low[0]) + len(ind_FP_low[0])

            # print(nr_low_response)
            # print(len(ind_TN_low[0]))
            # print(len(ind_TP_low[0]))
            # print(len(ind_FN_low[0]))
            # print(len(ind_FP_low[0]))

            per_accuracy_high = (nr_TN_high + nr_TP_high) / nr_high_response
            per_accuracy_low = (nr_TN_low + nr_TP_low) / nr_low_response

            per_accuracy_all = (nr_TN_low + nr_TP_high) / n_response

            accuracies_high.append(per_accuracy_high * 100)
            accuracies_low.append(per_accuracy_low * 100)
            accuracies_all.append(per_accuracy_all * 100)

            # get correct/incorrect indexes
            correct_inds, incorrect_inds = helper.correct_incorrect_indexes(recog_response, ground_truth)

            # remap response
            remapped_response = helper.remap_response(recog_response)

            # Get the mean confidence for correctness
            m_conf_all.append([np.mean(remapped_response[correct_inds]), np.mean(remapped_response[incorrect_inds])])

    # Plot the percentage responses
    response_old = np.asarray([response_1_old, response_2_old, response_3_old, response_4_old,
                               response_5_old, response_6_old])
    response_new = np.asarray([response_1_new, response_2_new, response_3_new, response_4_new,
                               response_5_new, response_6_new])

    response_percentage_old = np.mean(response_old, axis=1)
    std_old = np.std(response_old, axis=1)
    se_old = std_old/np.sqrt(n)
    response_percentage_new = np.mean(response_new, axis=1)
    std_new = np.std(response_new, axis=1)
    se_new = std_new/np.sqrt(n)

    x = [i for i in range(1, 7, 1)]
    axs[0, 0].errorbar(x, response_percentage_old, yerr=se_old, color='blue', label='old stimuli')
    axs[0, 0].errorbar(x, response_percentage_new, yerr=se_new, color='red', label='new stimuli')
    axs[0, 0].legend()
    axs[0, 0].set_xlabel('Confidence')
    axs[0, 0].set_ylabel('Probability of Response')
    axs[0, 0].set_title('n=' + str(len(filenames)) + ' sessions')

    # Other settings for cumulative ROC
    axs[0, 1].plot([0, 1], [0, 1], color='black', alpha=0.7)
    axs[0, 1].set_xlabel('false alarm rate')
    axs[0, 1].set_ylabel('hit rate')
    axs[0, 1].set_title('average roc')

    # Calculate the average and overall performance
    avg_performance = np.average(all_performances, axis=0)
    std_performance = np.std(all_performances, axis=0)

    # Plot the overall performance
    for performance in all_performances:
        axs[0, 2].plot(performance[0], performance[1], marker='.', color='grey', alpha=0.6)
        axs[0, 2].set_ylim(0, 1)
        axs[0, 2].set_xlim(0, 1)
    axs[0, 2].plot([0, 1], [0, 1], color='black', alpha=0.7)
    axs[0, 2].errorbar(avg_performance[0], avg_performance[1], std_performance[1], std_performance[0])
    axs[0, 2].set_xlabel('false alarm rate')
    axs[0, 2].set_ylabel('hit rate')
    axs[0, 2].set_title('Overall Performance mTP=' + str(avg_performance[0]) + ' mFP=' + str(avg_performance[1]))

    # Plot AUC histogram
    m_auc = np.mean(all_auc)
    axs[1, 0].hist(all_auc, 15, histtype='bar')
    axs[1, 0].set_xlim(0.5, 1)
    axs[1, 0].set_xlabel('AUC')
    axs[1, 0].set_ylabel('nr of subjects')
    axs[1, 0].set_title('AUC m=' + str(m_auc))

    # Plot the accuracies of different confidence level
    p1 = stats.ttest_1samp(accuracies_high, 50)[1]
    p2 = stats.ttest_1samp(accuracies_low, 50)[1]
    x_axis_label_high = 'high p=' + str(p1)
    x_axis_label_low = 'low p=' + str(p2)
    x_axis = [x_axis_label_high, x_axis_label_low]

    for i in range(len(accuracies_high)):
        axs[1, 1].plot(x_axis, [accuracies_high[i], accuracies_low[i]], marker='o', alpha=0.5)
    axs[1, 1].plot(x_axis, [50, 50], color='black')
    axs[1, 1].set_ylim([0, 100])

    tstat, p_val = stats.ttest_ind(accuracies_high, accuracies_low, equal_var=False)
    axs[1, 1].set_title('p=' + str(p_val))
    axs[1, 1].set_xlabel('confidence p vs. 50%')
    axs[1, 1].set_ylabel('accuracy % correct')

    # Calculate the mean and standard deviation for the confidence for correctness level
    m_conf_all = np.asarray(m_conf_all)
    m_conf = np.mean(m_conf_all, axis=0)
    std_conf = np.std(m_conf_all, axis=0)

    n = m_conf_all.shape[0]

    se_conf = std_conf/np.sqrt(n)
    tstat, p_val = stats.ttest_ind(m_conf_all[:, 0], m_conf_all[:, 1], equal_var=False)

    axs[1, 2].bar(['correct', 'incorrect'], m_conf, yerr=se_conf)
    axs[1, 2].set_ylabel('confidence 1=high, 3=guess')
    axs[1, 2].set_title('pT2=' + str(p_val) + ' n=' + str(n))

    plt.show()


# Functions that plot the graphs seperately.

def plot_prob_response():
    """
    Plot single graph of probability of response
    """
    filenames = helper.get_nwbfile_names("../data")
    x = [i for i in range(1, 7, 1)]
    response_percentage_old, std_old, response_percentage_new, std_new = helper.extract_probability_response(filenames)
                                                                                                      #type="old")
    plt.errorbar(x, response_percentage_old, yerr=std_old, color='blue', label='old stimuli')
    plt.errorbar(x, response_percentage_new, yerr=std_new, color='red', label='new stimuli')
    plt.legend(bbox_to_anchor=(1, 1), bbox_transform=plt.gcf().transFigure)
    plt.xlabel('Confidence')
    plt.ylabel('Probability of Response')
    plt.title('n=' + str(len(filenames)) + ' sessions')
    plt.show()


def plot_cumulative_roc():
    """
    Plot the cumulative roc
    """
    filenames = get_nwbfile_names("../data")
    for filename in filenames:
        nwbfile = read(filename)
        stats_all = cal_cumulative_d(nwbfile)
        x = stats_all[0:5, 4]
        y = stats_all[0:5, 3]
        plt.plot(x, y, marker='.', color='grey', alpha=0.5)
        plt.ylim(0, 1)
        plt.xlim(0, 1)
    plt.plot([0, 1], [0, 1], color='black', alpha=0.7)
    plt.xlabel('false alarm rate')
    plt.ylabel('hit rate')
    plt.title('average roc')
    plt.show()


def plot_overall_performance():
    """
    Plot overall performance
    """
    filenames = helper.get_nwbfile_names("../data")
    all_performances = []
    for filenames in filenames:
        nwbfile = helper.read(filenames)
        stats_all = helper.cal_cumulative_d(nwbfile)
        all_performances.append([stats_all[2, 4], stats_all[2, 3]])

    avg_performance = np.average(all_performances, axis=0)
    std_performance = np.std(all_performances, axis=0)

    for performance in all_performances:
        plt.plot(performance[0], performance[1], marker='.', color='grey', alpha=0.6)
        plt.ylim(0, 1)
        plt.xlim(0, 1)
    plt.plot([0, 1], [0, 1], color='black', alpha=0.7)
    plt.errorbar(avg_performance[0], avg_performance[1], std_performance[1], std_performance[0])
    plt.xlabel('false alarm rate')
    plt.ylabel('hit rate')
    plt.title('Overall Performance mTP=' + str(avg_performance[0]) + ' mFP=' + str(avg_performance[1]))
    plt.show()


def plot_auc():
    """
    Plot histogram of AUC
    """
    filenames = get_nwbfile_names("../data")
    all_auc = []
    for filenames in filenames:
        nwbfile = read(filenames)
        stats_all = cal_cumulative_d(nwbfile)
        auc = cal_auc(stats_all)
        all_auc.append(auc)
    m_auc = np.mean(all_auc)
    plt.hist(all_auc, 15, histtype='bar')
    plt.xlim(0, 1)
    plt.xlabel('AUC')
    plt.ylabel('nr of subjects')
    plt.title('AUC m=' + str(m_auc))
    plt.show()


def plot_confidence_accuracy():
    """
    Plot accuracy over confidence high low.
    """
    filenames = get_nwbfile_names("../data")

    accuracies_high = []
    accuracies_low = []
    accuracies_all = []

    for filename in filenames:
        nwbfile = read(filename)
        recog_response = extract_recog_responses(nwbfile)
        ground_truth = extract_new_old_label(nwbfile)
        split_status, split_mode, ind_TP_high, ind_TP_low, ind_FP_high, ind_FP_low, ind_TN_high, \
        ind_TN_low, ind_FN_high, ind_FN_low, n_response = dynamic_split(recog_response, ground_truth)
        nr_TN_high = len(ind_TN_high[0])
        nr_TP_high = len(ind_TP_high[0])
        nr_TN_all = len(ind_TN_high[0]) + len(ind_TN_low[0])
        nr_TN_low = len(ind_TP_high[0]) + len(ind_TP_low[0])
        nr_TP_low = len(ind_TP_low[0])
        nr_TN_low = len(ind_TN_low[0])

        nr_high_response = len(ind_TN_high[0]) + len(ind_TP_high[0]) + len(ind_FN_high[0]) + len(ind_FP_high[0])
        nr_low_response = len(ind_TN_low[0]) + len(ind_TP_low[0]) + len(ind_FN_low[0]) + len(ind_FP_low[0])

        per_accuracy_high = (nr_TN_high + nr_TP_high) / nr_high_response
        per_accuracy_low = (nr_TN_low + nr_TP_low) / nr_low_response

        per_accuracy_all = (nr_TN_low + nr_TP_high) / n_response

        accuracies_high.append(per_accuracy_high*100)
        accuracies_low.append(per_accuracy_low*100)
        accuracies_all.append(per_accuracy_all*100)

    p1 = stats.ttest_1samp(accuracies_high, 50)[1]
    p2 = stats.ttest_1samp(accuracies_low, 50)[1]
    x_axis_label_high = 'high p=' + str(p1)
    x_axis_label_low = 'low p=' + str(p2)
    x_axis = [x_axis_label_high, x_axis_label_low]

    for i in range(len(accuracies_high)):
        plt.plot(x_axis, [accuracies_high[i], accuracies_low[i]], marker='o')
    plt.plot(x_axis, [50, 50], color='black')
    plt.ylim([0, 100])

    tstat, p_val = stats.ttest_ind(accuracies_high, accuracies_low, equal_var=False)
    plt.title('p=' + str(p_val))
    plt.xlabel('confidence p vs. 50%')
    plt.ylabel('accuracy % correct')
    plt.show()
