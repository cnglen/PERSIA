import os
import sys
from importlib.metadata import PackageNotFoundError, version

# note: python -m build, xx.so -> site-packages/persia/xx.so, can't find persia_core
# manual add the path to avoid "ModuleNotFoundError: No module named 'persia_core'"
sys.path.append(os.path.dirname(os.path.realpath(__file__)))

try:
    __version__ = version("persia")
except PackageNotFoundError:
    # package is not installed
    pass

from persia import ctx as ctx
from persia import data as data
from persia import embedding as embedding
from persia import logger as logger
from persia import prelude as prelude
from persia import service as service
from persia import utils as utils
