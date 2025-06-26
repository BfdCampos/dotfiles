#!/usr/bin/env python3
"""
Dotfiles Setup Script

A modular, extensible dotfiles management system.
"""

import os
import sys
import argparse
from pathlib import Path

# Add lib directory to path
sys.path.insert(0, str(Path(__file__).parent))

from lib.utils import (
    load_yaml_config, print_info, print_success, print_error, 
    print_warning, Colors
)
from lib.backup import BackupManager
from lib.symlinks import SymlinkManager
from lib.installers import PackageInstaller


def parse_arguments():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description='Dotfiles setup and management tool',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                    # Interactive setup
  %(prog)s --yes              # Non-interactive, accept all
  %(prog)s --dry-run          # Preview changes
  %(prog)s --only-symlinks    # Only create symlinks
  %(prog)s --only-packages    # Only install packages
  %(prog)s --config custom.yaml # Use custom config file
        """
    )
    
    parser.add_argument(
        '-y', '--yes',
        action='store_true',
        help='Non-interactive mode, accept all prompts'
    )
    
    parser.add_argument(
        '-n', '--dry-run',
        action='store_true',
        help='Preview changes without making them'
    )
    
    parser.add_argument(
        '--force',
        action='store_true',
        help='Force overwrite without backup'
    )
    
    parser.add_argument(
        '--only-symlinks',
        action='store_true',
        help='Only create symlinks, skip package installation'
    )
    
    parser.add_argument(
        '--only-packages',
        action='store_true',
        help='Only install packages, skip symlink creation'
    )
    
    parser.add_argument(
        '--no-backup',
        action='store_true',
        help='Skip backing up existing files'
    )
    
    parser.add_argument(
        '-c', '--config',
        default='config/dotfiles.yaml',
        help='Path to configuration file (default: config/dotfiles.yaml)'
    )
    
    parser.add_argument(
        '--packages-config',
        default='config/packages.yaml',
        help='Path to packages configuration file (default: config/packages.yaml)'
    )
    
    return parser.parse_args()


def setup_symlinks(config: dict, args: argparse.Namespace, dotfiles_dir: str) -> bool:
    """Set up symlinks based on configuration."""
    print_info("\n=== Setting up symlinks ===")
    
    symlinks_config = config.get('symlinks', [])
    if not symlinks_config:
        print_warning("No symlinks configured")
        return True
        
    # Set up backup manager
    backup_manager = None
    if not args.no_backup and not args.force:
        backup_config = config.get('backup', {})
        if backup_config.get('enabled', True):
            backup_manager = BackupManager(
                backup_dir=backup_config.get('directory', '~/dotfiles_backup'),
                timestamp_format=backup_config.get('timestamp_format', '%Y%m%d_%H%M%S')
            )
    
    # Create symlink manager
    symlink_manager = SymlinkManager(
        dotfiles_dir=dotfiles_dir,
        backup_manager=backup_manager,
        interactive=not args.yes,
        force=args.force,
        dry_run=args.dry_run
    )
    
    # Create symlinks
    try:
        created = symlink_manager.create_symlinks_from_config(symlinks_config)
        print_success(f"\nCreated {created}/{len(symlinks_config)} symlinks")
        return True
    except Exception as e:
        print_error(f"Error creating symlinks: {e}")
        if not args.dry_run:
            symlink_manager.rollback()
        return False


def install_packages(packages_config: dict, args: argparse.Namespace) -> bool:
    """Install packages based on configuration."""
    print_info("\n=== Installing packages ===")
    
    packages = packages_config.get('packages', {})
    if not packages:
        print_warning("No packages configured")
        return True
        
    # Create package installer
    installer = PackageInstaller(
        interactive=not args.yes,
        dry_run=args.dry_run
    )
    
    # Install packages
    success_count = 0
    for package_name, package_config in packages.items():
        package_config['name'] = package_name
        
        # Handle custom installers
        if 'custom_installer' in package_config:
            custom_name = package_config['custom_installer']
            if installer.run_custom_installer(custom_name, package_config):
                success_count += 1
        else:
            if installer.install_package(package_config):
                success_count += 1
                
    # Handle Oh My Zsh plugins separately if configured
    if 'oh_my_zsh_plugins' in packages_config:
        if installer.install_oh_my_zsh_plugins(packages_config['oh_my_zsh_plugins']):
            success_count += 1
            
    print_success(f"\nInstalled {success_count}/{len(packages)} packages")
    return True


def main():
    """Main entry point."""
    args = parse_arguments()
    
    # Determine base directory
    script_dir = Path(__file__).parent.resolve()
    
    # Print header
    print(f"{Colors.CYAN.value}")
    print("╔══════════════════════════════════╗")
    print("║      Dotfiles Setup Tool         ║")
    print("╚══════════════════════════════════╝")
    print(f"{Colors.RESET.value}")
    
    if args.dry_run:
        print_warning("DRY RUN MODE - No changes will be made")
    
    # Load configurations
    try:
        config_path = script_dir / args.config
        config = load_yaml_config(str(config_path))
        
        packages_config = {}
        if not args.only_symlinks:
            packages_config_path = script_dir / args.packages_config
            packages_config = load_yaml_config(str(packages_config_path))
    except Exception as e:
        print_error(f"Failed to load configuration: {e}")
        return 1
    
    # Apply settings from config if not overridden by command line
    settings = config.get('settings', {})
    if not args.yes and settings.get('interactive') is False:
        args.yes = True
    if not args.dry_run and settings.get('dry_run'):
        args.dry_run = True
    if not args.force and settings.get('force'):
        args.force = True
    
    success = True
    
    # Set up symlinks
    if not args.only_packages:
        success = setup_symlinks(config, args, str(script_dir)) and success
    
    # Install packages
    if not args.only_symlinks:
        success = install_packages(packages_config, args) and success
    
    # Print summary
    print(f"\n{Colors.CYAN.value}")
    print("╔══════════════════════════════════╗")
    if success:
        print("║    ✅ Setup Complete! ✅          ║")
    else:
        print("║    ⚠️  Setup Incomplete ⚠️         ║")
    print("╚══════════════════════════════════╝")
    print(f"{Colors.RESET.value}")
    
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())