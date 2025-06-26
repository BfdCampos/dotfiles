"""Dotfiles management library."""

from .utils import Colors, get_user_confirmation, print_status
from .backup import BackupManager
from .symlinks import SymlinkManager
from .installers import PackageInstaller

__all__ = [
    'Colors',
    'get_user_confirmation',
    'print_status',
    'BackupManager',
    'SymlinkManager',
    'PackageInstaller',
]