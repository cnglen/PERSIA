from importlib.metadata import PackageNotFoundError, version

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
