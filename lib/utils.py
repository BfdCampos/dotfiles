"""Utility functions for dotfiles management."""

import os
import sys
import yaml
from enum import Enum
from typing import Dict, Any, Optional


class Colors(Enum):
    """Terminal color codes."""
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    RESET = '\033[0m'


def print_status(message: str, color: Colors = Colors.BLUE) -> None:
    """Print a colored status message."""
    print(f"{color.value}{message}{Colors.RESET.value}")


def print_error(message: str) -> None:
    """Print an error message."""
    print_status(f"❌ {message}", Colors.RED)


def print_success(message: str) -> None:
    """Print a success message."""
    print_status(f"✅ {message}", Colors.GREEN)


def print_warning(message: str) -> None:
    """Print a warning message."""
    print_status(f"⚠️  {message}", Colors.YELLOW)


def print_info(message: str) -> None:
    """Print an info message."""
    print_status(f"ℹ️  {message}", Colors.BLUE)


def get_user_confirmation(message: str, default: bool = False) -> bool:
    """Get yes/no confirmation from user."""
    default_str = "Y/n" if default else "y/N"
    
    while True:
        user_input = input(f"{Colors.YELLOW.value}{message} ({default_str}) {Colors.RESET.value}").lower().strip()
        
        if not user_input:
            return default
            
        if user_input in ['y', 'yes']:
            return True
        elif user_input in ['n', 'no']:
            return False
        else:
            print_error("Invalid input. Please enter 'y' or 'n'.")


def load_yaml_config(config_path: str) -> Dict[str, Any]:
    """Load YAML configuration file."""
    try:
        with open(config_path, 'r') as f:
            return yaml.safe_load(f)
    except FileNotFoundError:
        print_error(f"Configuration file not found: {config_path}")
        sys.exit(1)
    except yaml.YAMLError as e:
        print_error(f"Error parsing YAML file: {e}")
        sys.exit(1)


def expand_path(path: str) -> str:
    """Expand user home directory and environment variables in path."""
    return os.path.expandvars(os.path.expanduser(path))


def ensure_directory_exists(path: str) -> None:
    """Create directory if it doesn't exist."""
    directory = os.path.dirname(path) if os.path.isfile(path) else path
    if directory and not os.path.exists(directory):
        os.makedirs(directory)
        print_info(f"Created directory: {directory}")


def check_platform() -> str:
    """Get the current platform identifier."""
    import platform
    system = platform.system().lower()
    
    if system == 'darwin':
        return 'darwin'
    elif system == 'linux':
        return 'linux'
    else:
        return system