"""Package installation management."""

import os
import subprocess
from typing import Dict, List, Any, Optional
from .utils import check_platform, print_info, print_error, print_success, print_warning, get_user_confirmation, expand_path


class PackageInstaller:
    """Manages package installation across different platforms."""
    
    def __init__(self, interactive: bool = True, dry_run: bool = False):
        """Initialize package installer.
        
        Args:
            interactive: Whether to ask for confirmation
            dry_run: Whether to preview changes without making them
        """
        self.interactive = interactive
        self.dry_run = dry_run
        self.platform = check_platform()
        
    def check_command_exists(self, command: List[str]) -> bool:
        """Check if a command exists on the system."""
        try:
            subprocess.run(command, capture_output=True, check=True)
            return True
        except (subprocess.CalledProcessError, FileNotFoundError):
            return False
            
    def run_command(self, command: List[str], check: bool = True) -> Optional[subprocess.CompletedProcess]:
        """Run a shell command.
        
        Args:
            command: Command to run as list of strings
            check: Whether to check return code
            
        Returns:
            CompletedProcess result or None if dry run
        """
        if self.dry_run:
            print_info(f"[DRY RUN] Would run: {' '.join(command)}")
            return None
            
        try:
            result = subprocess.run(command, capture_output=True, text=True, check=check)
            return result
        except subprocess.CalledProcessError as e:
            print_error(f"Command failed: {' '.join(command)}")
            if e.stderr:
                print_error(f"Error: {e.stderr}")
            raise
            
    def install_with_homebrew(self, package: str) -> bool:
        """Install package using Homebrew."""
        if not self.check_command_exists(["brew", "--version"]):
            print_error("Homebrew is not installed")
            return False
            
        print_info(f"Installing {package} with Homebrew...")
        try:
            self.run_command(["brew", "install", package])
            print_success(f"{package} installed successfully")
            return True
        except subprocess.CalledProcessError:
            return False
            
    def install_with_apt(self, packages: List[str]) -> bool:
        """Install packages using apt."""
        if not self.check_command_exists(["apt", "--version"]):
            print_error("apt is not available")
            return False
            
        print_info(f"Installing {', '.join(packages)} with apt...")
        try:
            # Update package list first
            self.run_command(["sudo", "apt", "update"])
            # Install packages
            self.run_command(["sudo", "apt", "install", "-y"] + packages)
            print_success(f"{', '.join(packages)} installed successfully")
            return True
        except subprocess.CalledProcessError:
            return False
            
    def install_package(self, package_config: Dict[str, Any]) -> bool:
        """Install a package based on configuration.
        
        Args:
            package_config: Package configuration dict
            
        Returns:
            True if installed successfully
        """
        name = package_config.get('name', 'Unknown')
        description = package_config.get('description', '')
        
        if self.interactive and package_config.get('optional', True):
            prompt = f"Install {name}?"
            if description:
                prompt += f" ({description})"
            if not get_user_confirmation(prompt):
                print_info(f"Skipping {name}")
                return False
                
        installers = package_config.get('installers', {})
        platform_config = installers.get(self.platform)
        
        if not platform_config:
            print_warning(f"No installer configured for {name} on {self.platform}")
            return False
            
        method = platform_config.get('method')
        
        if method == 'homebrew':
            package_name = platform_config.get('package', name)
            return self.install_with_homebrew(package_name)
        elif method == 'apt':
            packages = platform_config.get('packages', [platform_config.get('package', name)])
            if isinstance(packages, str):
                packages = [packages]
            return self.install_with_apt(packages)
        elif method == 'custom':
            custom_installer = platform_config.get('installer')
            if custom_installer:
                return self.run_custom_installer(custom_installer, package_config)
        else:
            print_error(f"Unknown installation method: {method}")
            return False
            
        # Run post-install actions
        if 'post_install' in package_config:
            self.run_post_install_actions(package_config['post_install'])
            
        return True
        
    def run_post_install_actions(self, actions: List[Dict[str, Any]]) -> None:
        """Run post-installation actions."""
        for action in actions:
            action_type = action.get('action')
            
            if action_type == 'create_directory':
                path = expand_path(action.get('path', ''))
                if path and not os.path.exists(path):
                    if not self.dry_run:
                        os.makedirs(path)
                    print_info(f"Created directory: {path}")
                    
    def install_oh_my_zsh_plugins(self, config: Dict[str, Any]) -> bool:
        """Install Oh My Zsh plugins and themes."""
        if self.interactive and config.get('optional', True):
            if not get_user_confirmation("Install Oh My Zsh plugins and themes?"):
                return False
                
        zsh_custom = expand_path(os.environ.get('ZSH_CUSTOM', '~/.oh-my-zsh/custom'))
        
        # Install plugins
        plugins = config.get('plugins', [])
        for plugin in plugins:
            plugin_name = plugin.get('name')
            plugin_url = plugin.get('url')
            plugin_path = plugin.get('path')
            
            if not all([plugin_name, plugin_url, plugin_path]):
                continue
                
            full_path = os.path.join(zsh_custom, plugin_path)
            
            if os.path.exists(full_path):
                print_info(f"{plugin_name} already installed")
                continue
                
            print_info(f"Installing {plugin_name}...")
            try:
                self.run_command(["git", "clone", plugin_url, full_path])
                print_success(f"{plugin_name} installed")
            except subprocess.CalledProcessError:
                print_error(f"Failed to install {plugin_name}")
                
        # Install themes
        themes = config.get('themes', [])
        for theme in themes:
            theme_name = theme.get('name')
            theme_url = theme.get('url')
            theme_path = theme.get('path')
            clone_args = theme.get('clone_args', [])
            
            if not all([theme_name, theme_url, theme_path]):
                continue
                
            full_path = os.path.join(zsh_custom, theme_path)
            
            if os.path.exists(full_path):
                print_info(f"{theme_name} already installed")
                continue
                
            print_info(f"Installing {theme_name}...")
            try:
                cmd = ["git", "clone"] + clone_args + [theme_url, full_path]
                self.run_command(cmd)
                print_success(f"{theme_name} installed")
            except subprocess.CalledProcessError:
                print_error(f"Failed to install {theme_name}")
                
        return True
        
    def run_custom_installer(self, installer_name: str, config: Dict[str, Any]) -> bool:
        """Run a custom installer method."""
        if installer_name == 'install_oh_my_zsh_plugins':
            return self.install_oh_my_zsh_plugins(config)
        else:
            print_error(f"Unknown custom installer: {installer_name}")
            return False