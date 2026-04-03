from pytracking.evaluation import Tracker, get_dataset, trackerlist

MAIN_ECO_PARAMETER = 'verified_otb936_main'
MAIN_ECO_RUN_ID = 953
MAIN_ECO_DISPLAY_NAME = 'MyTrackerECO-Main'


def atom_nfs_uav():
    # Run three runs of ATOM on NFS and UAV datasets
    trackers = trackerlist('atom', 'default', range(3))

    dataset = get_dataset('nfs', 'uav')
    return trackers, dataset


def uav_test():
    # Run DiMP18, ATOM and ECO on the UAV dataset
    trackers = trackerlist('dimp', 'dimp18', range(1)) + \
               trackerlist('atom', 'default', range(1)) + \
               trackerlist('eco', 'default', range(1))

    dataset = get_dataset('uav')
    return trackers, dataset


def eco_verified_otb936_otb():
    trackers = [Tracker('eco', MAIN_ECO_PARAMETER, MAIN_ECO_RUN_ID, MAIN_ECO_DISPLAY_NAME)]
    dataset = get_dataset('otb')
    return trackers, dataset


def eco_verified_otb936_otb_easy3():
    trackers = [Tracker('eco', MAIN_ECO_PARAMETER, MAIN_ECO_RUN_ID, MAIN_ECO_DISPLAY_NAME)]

    from pytracking.evaluation.otbdataset import OTBDataset

    wanted = {'Deer', 'DragonBaby', 'Ironman'}
    dataset_obj = OTBDataset()
    dataset_obj.sequence_info_list = [s for s in dataset_obj.sequence_info_list if s['name'] in wanted]
    dataset = dataset_obj.get_sequence_list()
    return trackers, dataset


def eco_verified_otb936_lasot():
    trackers = [Tracker('eco', MAIN_ECO_PARAMETER, MAIN_ECO_RUN_ID, MAIN_ECO_DISPLAY_NAME)]
    dataset = get_dataset('lasot')
    return trackers, dataset


def eco_verified_otb936_lasot_first20():
    trackers = [Tracker('eco', MAIN_ECO_PARAMETER, MAIN_ECO_RUN_ID, MAIN_ECO_DISPLAY_NAME)]
    dataset = get_dataset('lasot')
    return trackers, dataset[:20]


def eco_verified_otb936_lasot_headtail40():
    trackers = [Tracker('eco', MAIN_ECO_PARAMETER, MAIN_ECO_RUN_ID, MAIN_ECO_DISPLAY_NAME)]
    dataset = get_dataset('lasot')
    return trackers, dataset[:20] + dataset[-20:]
