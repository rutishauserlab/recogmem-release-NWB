# Trial class


class Trial:
    def __init__(self, category_recog, category_name_recog, new_old_recog, response_recog, category_learn,
                 category_name_learn, response_learn, file_path_recog, file_path_learn, stimuli_id, trial_timestamps_recog,
                 trial_timestamps_learn):
        self._category_recog = category_recog
        self._new_old_recog = new_old_recog
        self._response_recog = response_recog
        self._category_name_recog = category_name_recog
        self._category_learn = category_learn
        self._category_name_learn = category_name_learn
        self._response_learn = response_learn
        self._file_path_learn = file_path_learn
        self._file_path_recog = file_path_recog
        self._stimuli_id = stimuli_id
        self._trial_timestamps_recog = trial_timestamps_recog
        self._trial_timestamps_learn = trial_timestamps_learn

    @property
    def response_learn(self):
        return self._response_learn

    @property
    def category_recog(self):
        return self._category_recog

    @property
    def category_learn(self):
        return self._category_learn

    @property
    def category_name_learn(self):
        return self._category_name_learn

    @property
    def new_old_recog(self):
        return self._new_old_recog

    @property
    def response_recog(self):
        return self._response_recog

    @property
    def category_name_recog(self):
        return self._category_name_recog

    @property
    def file_path_learn(self):
        return self._file_path_learn

    @property
    def file_path_recog(self):
        return self._file_path_recog

    @property
    def stimuli_id(self):
        return self._stimuli_id

    @property
    def trial_timestamps_recog(self):
        return self._trial_timestamps_recog

    @property
    def trial_timestamps_learn(self):
        return self._trial_timestamps_learn

    def win_spike_count(self, win_start, win_end, experiment_type='recog'):
        """
        Calculate the spike count in a window
        :param win_start: window starting time in millisecond
        :param win_end: window ending time in millisecond
        :param experiment_type: the experiment type, 'recog' or 'learn'
        :return: spike count in the window
        """
        start = win_start * 1000
        end = win_end * 1000

        timestamps_within_window = []
        if experiment_type == 'recog':
            timestamps_within_window = self._trial_timestamps_recog[(self._trial_timestamps_recog > start) *
                                                                    (self._trial_timestamps_recog < end)]
        elif experiment_type == 'learn':
            timestamps_within_window = self._trial_timestamps_learn[(self._trial_timestamps_learn > start) *
                                                                    (self._trial_timestamps_learn < end)]
        return len(timestamps_within_window)

    def win_spike_rate(self, win_start, win_end, experiment_type='recog'):
        """
        Calculate the spike count rate in a window
        :param win_start:
        :param win_end:
        :return: spike count rate in the window
        """
        start = win_start * 1000
        end = win_end * 1000

        timestamps_within_window = []
        if experiment_type == 'recog':
            timestamps_within_window = self._trial_timestamps_recog[(self._trial_timestamps_recog > start) *
                                                                    (self._trial_timestamps_recog < end)]
        elif experiment_type == 'learn':
            timestamps_within_window = self._trial_timestamps_learn[(self._trial_timestamps_learn > start) *
                                                                    (self._trial_timestamps_learn < end)]

        return len(timestamps_within_window) / ((end - start) / 1000000)
