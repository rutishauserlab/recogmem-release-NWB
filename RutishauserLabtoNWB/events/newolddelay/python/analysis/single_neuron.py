import RutishauserLabtoNWB.events.newolddelay.python.analysis.helper as helper
import numpy as np
import pandas as pd
from scipy.stats import f_oneway
import matplotlib.pyplot as plt
from scipy.ndimage import gaussian_filter1d



class Neuron:
    """
    The Neuron class is designed to contain neuron data and perform tests for MS and VS cells
    """
    def __init__(self):
        self.session_id = None
        self.channel_id = None
        self.neuron_id = None
        self.trials_learn = None
        self.trials_recog = None
        self.spike_timestamps = None

    def vs_test(self):
        """
        Perform statistical test to see if the neuron is a visually selective neuron
        :return: p value
        """
        trials = (trial for trial in self.trials_recog)
        cat_1 = []
        cat_2 = []
        cat_3 = []
        cat_4 = []
        cat_5 = []

        # The window that we want to look at is from 200 ms after stim on until 1500 ms after.
        for trial in trials:
            if trial.category_id == 1:
                cat_1.append(trial.win_spike_rate(self.spike_timestamps, 200, 1700))
            elif trial.category_id == 2:
                cat_2.append(trial.win_spike_rate(self.spike_timestamps, 200, 1700))
            elif trial.category_id == 3:
                cat_3.append(trial.win_spike_rate(self.spike_timestamps, 200, 1700))
            elif trial.category_id == 4:
                cat_4.append(trial.win_spike_rate(self.spike_timestamps, 200, 1700))
            elif trial.category_id == 5:
                cat_5.append(trial.win_spike_rate(self.spike_timestamps, 200, 1700))
        return f_oneway(cat_1, cat_2, cat_3, cat_4, cat_5)[1]

    def baseline_test(self):
        """
        Anova test to test the difference between the baseline rate and the stim on rate
        :return: p value of the anova test
        """
        trials = (trial for trial in self.trials_recog)
        baseline = []
        stim_period = []
        for trial in trials:
            baseline.append(trial.win_spike_rate(self.spike_timestamps, -1000, 0))
            stim_period.append(trial.win_spike_rate(self.spike_timestamps, 200, 1700))
        return f_oneway(baseline, stim_period)[1]

    def ms_test(self, n):
        """
        A bootstrap test for new old test
        :param n: number of bootstraps
        :return: a p value of the bootstrap test
        """
        trials = (trial for trial in self.trials_recog)

        old = np.array([])
        new = np.array([])

        # Calculate the spike rates for new and old stimuli
        for trial in trials:
            if (trial.label == 0) & (trial.response <= 3.):
                new = np.append(new, trial.win_spike_rate(self.spike_timestamps, 200, 1700))
            elif (trial.label == 1) & (trial.response >= 4.):
                old = np.append(old, trial.win_spike_rate(self.spike_timestamps, 200, 1700))

        # Ready for bootstrapping
        m_ = len(new)
        n_ = len(old)
        all_m = np.mean(np.concatenate([new, old]))

        new_m = new - np.mean(new) + all_m
        old_m = old - np.mean(old) + all_m
        new_bootstrap = np.array([])
        old_bootstrap = np.array([])

        # Bootstraping
        for i in range(0, n):
            random_ints = np.random.randint(m_, size=m_)
            new_samples = new_m[random_ints]
            new_bootstrap = np.append(new_bootstrap, np.mean(new_samples))

            random_ints = np.random.randint(n_, size=n_)
            old_samples = old_m[random_ints]
            old_bootstrap = np.append(old_bootstrap, np.mean(old_samples))

        t = np.abs(new_bootstrap - old_bootstrap)
        t_obs = np.abs(np.mean(new) - np.mean(old))

        return np.mean(t >= t_obs)

    def raster_psth(self, height_light_range=(1000, 2000), xlim=(0, 2500), cell_type='visual', bin_size=250, smooth = False,
                    saveFig = False):
        """
        The method to plot a raster (top) and psth (bottom) along with each other.
        :param height_light_range: The range where the graph has a light grey shading (1000, 2000)
        :param xlim: The x-axis limit
        :param cell_type: visual for 5 categories, memory for 2 categories (new/old)
        :param bin_size: The bin size when calculating the ptsh
        :return:
        """
        fig, axs = plt.subplots(nrows=2, ncols=1, sharex=True, figsize=(10, 9))
        if cell_type == 'visual':

            # Plot raster plot
            colors1 = np.array([[1, 0, 0],
                                [0, 1, 1],
                                [0, 0, 1],
                                [0, 1, 0],
                                [1, 0, 1]])
            trials = sorted(self.trials_recog, key=lambda trial: trial.category_id)
            color_mapping = [colors1[trial.category_id - 1] for trial in trials]
            trials_timestamps = [self.spike_timestamps[(self.spike_timestamps > (-1000000 + trial.stim_on)) &
                                                       (self.spike_timestamps < (trial.delay2_off))]-(-1000000+trial.stim_on)
                                 for trial in trials]

            axs[0].eventplot(np.asarray(trials_timestamps) / 1000, colors=color_mapping)
            axs[0].axvspan(height_light_range[0], height_light_range[1], color='grey', alpha=0.1)
            axs[0].set_xlim(xlim[0], xlim[1])
            axs[0].set_ylabel('Trials (resorted)')
            axs[0].set_title('Raster Plot ' + str(self.session_id) + ' ' + 'Channel: ' + str(self.channel_id) +
                             ' Cluster ID: ' + str(self.neuron_id))

            # Plot ptsh
            n_x = int(np.floor((xlim[1] - xlim[0]) / bin_size))

            # Separate the trials into sorted categories
            cat1_name = trials[0].category_name
            cat2_name = trials[20].category_name
            cat3_name = trials[40].category_name
            cat4_name = trials[60].category_name
            cat5_name = trials[80].category_name
            mean_rates = np.zeros([5, n_x])

            x_plot = np.zeros(n_x)

            # Calculate the mean rates for different bins
            for i in range(0, n_x):
                # meant rates for cat 1
                mean_rate = 0
                start = i * bin_size
                end = (i + 1) * bin_size
                x_plot[i] = start + bin_size / 2
                for trial in trials[0:20]:
                    mean_rate = mean_rate + trial.win_spike_rate(self.spike_timestamps, start-1000, end-1000)
                mean_rate = mean_rate / 20
                mean_rates[0][i] = mean_rate
                # meant rates for cat 2
                mean_rate = 0
                for trial in trials[20:40]:
                    mean_rate = mean_rate + trial.win_spike_rate(self.spike_timestamps, start-1000, end-1000)
                mean_rate = mean_rate / 20
                mean_rates[1][i] = mean_rate
                # meant rates for cat 3
                mean_rate = 0
                for trial in trials[40:60]:
                    mean_rate = mean_rate + trial.win_spike_rate(self.spike_timestamps, start-1000, end-1000)
                mean_rate = mean_rate / 20
                mean_rates[2][i] = mean_rate

                # meant rates for cat 4
                mean_rate = 0
                for trial in trials[60:80]:
                    mean_rate = mean_rate + trial.win_spike_rate(self.spike_timestamps, start-1000, end-1000)
                mean_rate = mean_rate / 20
                mean_rates[3][i] = mean_rate

                # meant rates for cat 5
                mean_rate = 0
                for trial in trials[80:100]:
                    mean_rate = mean_rate + trial.win_spike_rate(self.spike_timestamps, start-1000, end-1000)
                mean_rate = mean_rate / 20
                mean_rates[4][i] = mean_rate

            plt_df = pd.DataFrame({'Time (ms)': x_plot,
                                   cat1_name: mean_rates[0][:],
                                   cat2_name: mean_rates[1][:],
                                   cat3_name: mean_rates[2][:],
                                   cat4_name: mean_rates[3][:],
                                   cat5_name: mean_rates[4][:]})


            if smooth == False:
                axs[1].plot('Time (ms)', cat1_name, data=plt_df, marker='x', color=colors1[0])
                axs[1].plot('Time (ms)', cat2_name, data=plt_df, marker='x', color=colors1[1])
                axs[1].plot('Time (ms)', cat3_name, data=plt_df, marker='x', color=colors1[2])
                axs[1].plot('Time (ms)', cat4_name, data=plt_df, marker='x', color=colors1[3])
                axs[1].plot('Time (ms)', cat5_name, data=plt_df, marker='x', color=colors1[4])
                axs[1].set_xlim(xlim[0], xlim[1])
                axs[1].axvspan(height_light_range[0], height_light_range[1], color='grey', alpha=0.1)
                axs[1].legend()
                axs[1].set_ylabel('Spike Rate')
                axs[1].set_xlabel('Time (ms)')
                axs[1].set_title('PSTH ' + 'pVS=' + str(self.vs_test()))
                plt.show()
            else: #Smooth the PSTH
                gauss = gaussian_filter1d(mean_rates, 125)
                plt_df_gauss = pd.DataFrame({'Time (ms)': x_plot,
                                             cat1_name: gauss[0][:],
                                             cat2_name: gauss[1][:],
                                             cat3_name: gauss[2][:],
                                             cat4_name: gauss[3][:],
                                             cat5_name: gauss[4][:]})

                axs[1].plot('Time (ms)', cat1_name, data=plt_df_gauss, marker='x', color=colors1[0])
                axs[1].plot('Time (ms)', cat2_name, data=plt_df_gauss, marker='x', color=colors1[1])
                axs[1].plot('Time (ms)', cat3_name, data=plt_df_gauss, marker='x', color=colors1[2])
                axs[1].plot('Time (ms)', cat4_name, data=plt_df_gauss, marker='x', color=colors1[3])
                axs[1].plot('Time (ms)', cat5_name, data=plt_df_gauss, marker='x', color=colors1[4])
                axs[1].set_xlim(xlim[0], xlim[1])
                axs[1].axvspan(height_light_range[0], height_light_range[1], color='grey', alpha=0.1)
                axs[1].legend()
                axs[1].set_ylabel('Spike Rate')
                axs[1].set_xlabel('Time (ms)')
                axs[1].set_title('PSTH ' + 'pVS=' + str(self.vs_test()))
                plt.show()

                if saveFig == True:
                    fig.savefig('destination_path.eps',
                                format='eps', dpi=1000)


        elif cell_type == 'memory':
            # Plot raster plot
            colors1 = np.array([[1, 0, 0],
                                [0, 1, 1],
                                [0, 0, 1],
                                [0, 1, 0],
                                [1, 0, 1]])
            trials = sorted(self.trials_recog, key=lambda trial: trial.response)
            color_mapping = [colors1[int(trial.response > 3)] for trial in trials]
            trials_timestamps = [self.spike_timestamps[(self.spike_timestamps > (-1000000 + trial.stim_on)) &
                                                       (self.spike_timestamps < (trial.delay2_off))]-(-1000000+trial.stim_on)
                                 for trial in trials]

            axs[0].eventplot(np.asarray(trials_timestamps) / 1000, colors=color_mapping)
            axs[0].axvspan(height_light_range[0], height_light_range[1], color='grey', alpha=0.1)
            axs[0].set_xlim(xlim[0], xlim[1])
            axs[0].set_ylabel('Trials')
            axs[0].set_title('Raster Plot ' + str(self.session_id) + ' ' + 'Channel: ' + str(self.channel_id) +
                             ' Cluster ID: ' + str(self.neuron_id))

            # Plot psth
            cat1_name = 'New'
            cat2_name = 'Old'

            n_x = int(np.floor((xlim[1] - xlim[0]) / bin_size))

            mean_rates = np.zeros([2, n_x])
            x_plot = np.zeros(n_x)
            for i in range(0, n_x):
                # meant rates for cat 1
                mean_rate = 0
                start = i * bin_size
                end = (i + 1) * bin_size
                x_plot[i] = start + bin_size / 2
                for trial in trials[0:50]:
                    mean_rate = mean_rate + trial.win_spike_rate(self.spike_timestamps, start-1000, end-1000)
                mean_rate = mean_rate / 20
                mean_rates[0][i] = mean_rate
                # meant rates for cat 2
                mean_rate = 0
                for trial in trials[50:100]:
                    mean_rate = mean_rate + trial.win_spike_rate(self.spike_timestamps, start-1000, end-1000)
                mean_rate = mean_rate / 20
                mean_rates[1][i] = mean_rate

            if smooth == False:
                plt_df = pd.DataFrame({'Time (ms)': x_plot,
                                      cat1_name: mean_rates[0][:],
                                      cat2_name: mean_rates[1][:]})

                axs[1].plot('Time (ms)', cat1_name, data=plt_df, marker='x', color=colors1[0])
                axs[1].plot('Time (ms)', cat2_name, data=plt_df, marker='x', color=colors1[1])
                axs[1].set_xlim(xlim[0], xlim[1])
                axs[1].axvspan(height_light_range[0], height_light_range[1], color='grey', alpha=0.1)
                axs[1].legend()
                axs[1].set_ylabel('Spike Rate')
                axs[1].set_xlabel('Time (ms)')
                axs[1].set_title('PSTH ' + 'pMS=' + str(self.ms_test(10000)))
                plt.show()
            else: #Smooth the PSTH
                gauss = gaussian_filter1d(mean_rates, 125)
                plt_df_gauss = pd.DataFrame({'Time (ms)': x_plot,
                                             cat1_name: gauss[0][:],
                                             cat2_name: gauss[1][:]})

                axs[1].plot('Time (ms)', cat1_name, data=plt_df_gauss, marker='x', color=colors1[0])
                axs[1].plot('Time (ms)', cat2_name, data=plt_df_gauss, marker='x', color=colors1[1])
                axs[1].set_xlim(xlim[0], xlim[1])
                axs[1].axvspan(height_light_range[0], height_light_range[1], color='grey', alpha=0.1)
                axs[1].legend()
                axs[1].set_ylabel('Spike Rate')
                axs[1].set_xlabel('Time (ms)')
                axs[1].set_title('PSTH ' + 'pMS=' + str(self.ms_test(1000)))
                plt.show()


class Trial:
    def __int__(self):
        self.stim_on = None
        self.stim_off = None
        self.delay1_off = None
        self.delay2_off = None
        self.category_id = None
        self.category_name = None
        self.label = None
        self.response = None

    def win_spike_rate(self, spike_timestamps, start, end):
        """
        Calculate the spike rate of a given window
        :param spike_timestamps: The spike timestamps for the experiment
        :param start: starting of a window (a relative time, 0 at stim on)
        :param end: end time of a window (a relative time, 0 at stim on)
        :return: spike rate
        """
        start = start * 1000
        end = end * 1000

        timestamp_interested = spike_timestamps[(spike_timestamps > (start + self.stim_on)) &
                                                (spike_timestamps < (self.stim_on + end))]
        rate = len(timestamp_interested)/((end-start)/1000000)
        return rate


def extract_neuron_data_from_nwb(nwbfile):
    """
    A function to extract all the neuron data from a nwbfile
    A nwbfile is a session of the experiment
    :param nwbfile: nwbfile that contains the raw data
    :return: a list of neurons contained in the nwbfile
    """
    # initialize a empty placeholder for neurons
    neurons = []

    # Time scaling
    TIME_SCALING = 10**6

    # Graph necessary data from the nwbfile modules

    session_id = nwbfile.identifier

    response_recog, response_learn = helper.extract_response_from_nwbfile(nwbfile)


    stim_on = np.asarray(nwbfile.trials['start_time'].data) * TIME_SCALING
    stim_off = np.asarray(nwbfile.trials['stop_time'].data) * TIME_SCALING
    new_old_labels_recog = np.asarray(nwbfile.trials['new_old_labels_recog'].data)
    category_id = np.asarray(nwbfile.trials['stimCategory'].data).astype(int)
    delay1_off = np.asarray(nwbfile.trials['delay1_time'].data) * TIME_SCALING
    delay2_off = np.asarray(nwbfile.trials['delay2_time'].data) * TIME_SCALING
    category_name = np.asarray((nwbfile.trials['category_name'].data)).astype(str)
    stim_phase = np.asarray(nwbfile.trials['stim_phase'].data).astype(str)
    # Get Electrodes
    try:
        channels = np.asarray(nwbfile.units['electrodes'].target.data)
    except:
        channels = np.asarray(nwbfile.units['electrodes'].data)
    #Get Channel IDs
    channel_ids = np.asarray(nwbfile.electrodes['origChannel'].data)
    channel_ids = channel_ids[channels]
    #Get Cluster IDs
    clusterIDs = np.asarray(nwbfile.units['origClusterID'].data).astype(int)

    trials_learn = []
    trials_recog = []


    # Create the trial objects
    for i in range(len(category_id)):
            trial = Trial()
            trial.stim_on = stim_on[i]
            trial.stim_off = stim_off[i]
            trial.delay1_off = delay1_off[i]
            trial.delay2_off = delay2_off[i]
            trial.category_id = category_id[i]
            trial.category_name = category_name[i]
            if stim_phase[i] == 'learn':
                trial.response = response_learn[i].astype(int)
                trials_learn.append(trial)
            else:
                trial.label = int(new_old_labels_recog[i])
                trial.response = int(response_recog[i-100])
                trials_recog.append(trial)

    for channel in range(len(channels)):
        spike_timestamps = (np.asarray(nwbfile.units.get_unit_spike_times(channel))) * TIME_SCALING
        cell_ids = channels[channel]

        for cell_id in np.unique(cell_ids):
            this_neuron_spike_timestamps = spike_timestamps
            print('==============================================')
            print('Session_id: ', str(session_id))
            print('Channel: ', str(channel_ids[channel]))
            print('Cell_id: ', str(cell_id))
            print('Number of spikes: ' + str(len(this_neuron_spike_timestamps)))
            neuron = Neuron()
            neuron.session_id = session_id
            neuron.channel_id = channel_ids[channel]
            neuron.neuron_id = clusterIDs[channel]
            neuron.spike_timestamps = this_neuron_spike_timestamps
            neuron.trials_recog = trials_recog
            neuron.trials_learn = trials_learn
            neurons.append(neuron)

    return neurons





