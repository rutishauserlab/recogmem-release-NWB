# The cell.py file contains the cell associated classes
from scipy.stats import f_oneway
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd


class Cell:

    def __init__(self, cell_path, session_nr, session_name, cell_info, raw_spike_timestamps, trials):
        self._data_path = cell_path
        self._session_nr = session_nr
        self._session_name = session_name
        self._channel_nr = cell_info[0]
        self._cluster_id = cell_info[1]
        self._ori_cluster_id = cell_info[2]
        self._brain_area_id = cell_info[3]
        self._raw_spike_timestamps = raw_spike_timestamps
        self._trials = trials
        self._p_vs = self._vs_test()
        self._p_ms = self._ms_test(1000)
        self._p_vs_baseline = self._baseline_test()

    @property
    def p_vs(self):
        return self._p_vs

    @property
    def p_ms(self):
        return self._p_ms

    @property
    def p_vs_baseline(self):
        return self._p_vs_baseline

    @property
    def data_path(self):
        return self._data_path

    @property
    def session_nr(self):
        return self._session_nr

    @property
    def session_name(self):
        return self._session_name

    @property
    def channel_nr(self):
        return self._channel_nr

    @property
    def cluster_id(self):
        return self._cluster_id

    @property
    def ori_cluster_id(self):
        return self._ori_cluster_id

    @property
    def brain_area_id(self):
        return self._brain_area_id

    @property
    def raw_spike_timestamps(self):
        return self._raw_spike_timestamps

    @property
    def trials(self):
        return self._trials

    def _vs_test(self):
        """
        Anova test for stimuli categories
        :return: p value for the anova test
        """
        trials = (trial for trial in self.trials)
        cat_1 = []
        cat_2 = []
        cat_3 = []
        cat_4 = []
        cat_5 = []
        for trial in trials:
            if trial.category_recog == 1:
                cat_1.append(trial.win_spike_rate(1200, 2700))
            elif trial.category_recog == 2:
                cat_2.append(trial.win_spike_rate(1200, 2700))
            elif trial.category_recog == 3:
                cat_3.append(trial.win_spike_rate(1200, 2700))
            elif trial.category_recog == 4:
                cat_4.append(trial.win_spike_rate(1200, 2700))
            elif trial.category_recog == 5:
                cat_5.append(trial.win_spike_rate(1200, 2700))
        return f_oneway(cat_1, cat_2, cat_3, cat_4, cat_5)[1]

    def _baseline_test(self):
        """
        Anova test to test the difference between the baseline rate and the stim on rate
        :return: p value of the anova test
        """
        trials = (trial for trial in self.trials)
        baseline = []
        stim_period = []
        for trial in trials:
            baseline.append(trial.win_spike_rate(0, 1000))
            stim_period.append(trial.win_spike_rate(1200, 2700))
        return f_oneway(baseline, stim_period)[1]

    def _ms_test(self, n):
        """
        A bootstrap test for new old test
        :param n: number of bootstraps
        :return: a p value of the bootstrap test
        """
        trials = (trial for trial in self.trials)

        old = np.array([])
        new = np.array([])

        for trial in trials:
            if (trial.new_old_recog == 0) & (trial.response_recog <= 3.):
                new = np.append(new, trial.win_spike_rate(1200, 2700))
            elif (trial.new_old_recog == 1) & (trial.response_recog >= 4.):
                old = np.append(old, trial.win_spike_rate(1200, 2700))

        m_ = len(new)
        n_ = len(old)

        all_m = np.mean(np.concatenate([new, old]))

        new_m = new - np.mean(new) + all_m
        old_m = old - np.mean(old) + all_m
        new_bootstrap = np.array([])
        old_bootstrap = np.array([])
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

    def raster(self, height_light_range=(1000, 2000), xlim=(0, 2500)):
        colors1 = np.array([[1, 0, 0],
                            [0, 1, 1],
                            [0, 0, 1],
                            [0, 1, 0],
                            [1, 0, 1]])
        trials = sorted(self._trials, key=lambda trial: trial.category)
        color_mapping = [colors1[trial.category-1] for trial in trials]
        trials_timestamps = [trial.trial_timestamps for trial in trials]
        plt.eventplot(np.asarray(trials_timestamps)/1000, colors=color_mapping)
        plt.axvspan(height_light_range[0], height_light_range[1], color='grey', alpha=0.1)
        plt.xlim(xlim[0], xlim[1])
        plt.show()

    def psth(self, cell_type='visual', bin_size=250, xlim=(0, 2500), height_light_range=(1000, 2000)):

        n_x = int(np.floor((xlim[1] - xlim[0]) / bin_size))

        if cell_type == 'visual':
            trials = sorted(self._trials, key=lambda trial: trial.category_recog)

            colors1 = np.array([[1, 0, 0],
                                [0, 1, 1],
                                [0, 0, 1],
                                [0, 1, 0],
                                [1, 0, 1]])
            cat1_name = trials[0].category_name_recog
            cat2_name = trials[20].category_name_recog
            cat3_name = trials[40].category_name_recog
            cat4_name = trials[60].category_name_recog
            cat5_name = trials[80].category_name_recog
            mean_rates = np.zeros([5, n_x])

            x_plot = np.zeros(n_x)
            for i in range(0, n_x):
                # meant rates for cat 1
                mean_rate = 0
                start = i * bin_size
                end = (i + 1) * bin_size
                x_plot[i] = start + bin_size/2
                for trial in trials[0:20]:
                    mean_rate = mean_rate + trial.win_spike_rate(start, end)
                mean_rate = mean_rate/20
                mean_rates[0][i] = mean_rate
                # meant rates for cat 2
                mean_rate = 0
                for trial in trials[20:40]:
                    mean_rate = mean_rate + trial.win_spike_rate(start, end)
                mean_rate = mean_rate/20
                mean_rates[1][i] = mean_rate

                # meant rates for cat 3
                mean_rate = 0
                for trial in trials[40:60]:
                    mean_rate = mean_rate + trial.win_spike_rate(start, end)
                mean_rate = mean_rate/20
                mean_rates[2][i] = mean_rate

                # meant rates for cat 4
                mean_rate = 0
                for trial in trials[60:80]:
                    mean_rate = mean_rate + trial.win_spike_rate(start, end)
                mean_rate = mean_rate/20
                mean_rates[3][i] = mean_rate

                # meant rates for cat 5
                mean_rate = 0
                for trial in trials[80:100]:
                    mean_rate = mean_rate + trial.win_spike_rate(start, end)
                mean_rate = mean_rate/20
                mean_rates[4][i] = mean_rate

            plt_df = pd.DataFrame({'Time (ms)': x_plot,
                                   cat1_name: mean_rates[0][:],
                                   cat2_name: mean_rates[1][:],
                                   cat3_name: mean_rates[2][:],
                                   cat4_name: mean_rates[3][:],
                                   cat5_name: mean_rates[4][:]})

            plt.plot('Time (ms)', cat1_name, data=plt_df, marker='x', color=colors1[0])
            plt.plot('Time (ms)', cat2_name, data=plt_df, marker='x', color=colors1[1])
            plt.plot('Time (ms)', cat3_name, data=plt_df, marker='x', color=colors1[2])
            plt.plot('Time (ms)', cat4_name, data=plt_df, marker='x', color=colors1[3])
            plt.plot('Time (ms)', cat5_name, data=plt_df, marker='x', color=colors1[4])
            plt.xlim(xlim[0], xlim[1])
            plt.axvspan(height_light_range[0], height_light_range[1], color='grey', alpha=0.1)
            plt.legend()
            plt.show()

        elif cell_type == 'memory':
            trials = sorted(self._trials, key=lambda trial: trial.response_recog)
            colors1 = np.array([[1, 0, 0],
                                [0, 1, 1],
                                [0, 0, 1],
                                [0, 1, 0],
                                [1, 0, 1]])
            cat1_name = 'New'
            cat2_name = 'Old'
            mean_rates = np.zeros([2, n_x])
            x_plot = np.zeros(n_x)
            for i in range(0, n_x):
                # meant rates for cat 1
                mean_rate = 0
                start = i * bin_size
                end = (i + 1) * bin_size
                x_plot[i] = start + bin_size/2
                for trial in trials[0:50]:
                    mean_rate = mean_rate + trial.win_spike_rate(start, end)
                mean_rate = mean_rate / 20
                mean_rates[0][i] = mean_rate
                # meant rates for cat 2
                mean_rate = 0
                for trial in trials[50:100]:
                    mean_rate = mean_rate + trial.win_spike_rate(start, end)
                mean_rate = mean_rate / 20
                mean_rates[1][i] = mean_rate

            plt_df = pd.DataFrame({'Time (ms)': x_plot,
                                   cat1_name: mean_rates[0][:],
                                   cat2_name: mean_rates[1][:]})

            plt.plot('Time (ms)', cat1_name, data=plt_df, marker='x', color=colors1[0])
            plt.plot('Time (ms)', cat2_name, data=plt_df, marker='x', color=colors1[1])
            plt.xlim(xlim[0], xlim[1])
            plt.axvspan(height_light_range[0], height_light_range[1], color='grey', alpha=0.1)
            plt.legend()
            plt.show()


