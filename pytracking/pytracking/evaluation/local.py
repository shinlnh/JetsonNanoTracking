from pathlib import Path
import os

from pytracking.evaluation.environment import EnvSettings


def _find_project_root():
    env_root = os.environ.get('PROJECT_ROOT')
    if env_root:
        candidate = Path(env_root).expanduser().resolve()
        if (candidate / 'pytracking' / 'pytracking').is_dir():
            return candidate

    current = Path(__file__).resolve()
    for candidate in current.parents:
        if (candidate / 'pytracking' / 'pytracking').is_dir():
            return candidate

    raise FileNotFoundError('Could not locate project root containing pytracking/pytracking.')


def _pick_existing_path(*candidates):
    for candidate in candidates:
        if candidate and candidate.exists():
            return str(candidate)
    return str(candidates[0])


def local_env_settings():
    settings = EnvSettings()
    project_root = _find_project_root()
    pytracking_root = project_root / 'pytracking'
    pytracking_pkg_root = pytracking_root / 'pytracking'

    default_lasot = _pick_existing_path(
        project_root / 'lasot',
        project_root.parent / 'ls' / 'lasot',
        Path.home() / 'HELIOS' / 'ls' / 'lasot',
    )
    default_otb = _pick_existing_path(
        project_root / 'otb' / 'otb100',
        project_root.parent / 'otb' / 'otb100',
        Path.home() / 'HELIOS' / 'otb' / 'otb100',
    )

    # Set your local paths here.

    settings.davis_dir = ''
    settings.got10k_path = ''
    settings.got_packed_results_path = ''
    settings.got_reports_path = ''
    settings.lasot_extension_subset_path = ''
    settings.lasot_path = os.environ.get('MYECO_LASOT_PATH', default_lasot)
    settings.network_path = os.environ.get('MYECO_NETWORK_PATH', str(pytracking_root / 'pretrained_network'))    # Where tracking networks are stored.
    settings.nfs_path = ''
    settings.otb_path = os.environ.get('MYECO_OTB_PATH', default_otb)
    settings.oxuva_path = ''
    settings.result_plot_path = os.environ.get('MYECO_RESULT_PLOT_PATH', str(pytracking_pkg_root / 'result_plots'))
    settings.results_path = os.environ.get('MYECO_RESULTS_PATH', str(pytracking_pkg_root / 'tracking_results'))    # Where to store tracking results
    settings.segmentation_path = os.environ.get('MYECO_SEGMENTATION_PATH', str(pytracking_pkg_root / 'segmentation_results'))
    settings.tn_packed_results_path = ''
    settings.tpl_path = ''
    settings.trackingnet_path = ''
    settings.uav_path = ''
    settings.vot_path = ''
    settings.youtubevos_dir = ''
    return settings
