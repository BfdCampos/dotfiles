"""Symlink management for dotfiles."""

import os
from typing import Dict, List, Optional, Any
from .utils import expand_path, ensure_directory_exists, print_info, print_error, print_success, get_user_confirmation
from .backup import BackupManager


class SymlinkManager:
    """Manages creating and removing symlinks for dotfiles."""
    
    def __init__(self, dotfiles_dir: str, backup_manager: Optional[BackupManager] = None,
                 interactive: bool = True, force: bool = False, dry_run: bool = False):
        """Initialize symlink manager.
        
        Args:
            dotfiles_dir: Base directory containing dotfiles
            backup_manager: BackupManager instance for backing up existing files
            interactive: Whether to ask for confirmation
            force: Whether to overwrite without backup
            dry_run: Whether to preview changes without making them
        """
        self.dotfiles_dir = expand_path(dotfiles_dir)
        self.backup_manager = backup_manager
        self.interactive = interactive
        self.force = force
        self.dry_run = dry_run
        self.created_symlinks = []
        
    def create_symlink(self, source: str, destination: str, 
                      create_parent: bool = False, description: str = "") -> bool:
        """Create a single symlink.
        
        Args:
            source: Source file relative to dotfiles_dir
            destination: Destination path for symlink
            create_parent: Whether to create parent directories
            description: Description of the symlink
            
        Returns:
            True if symlink was created successfully
        """
        source_path = os.path.join(self.dotfiles_dir, source)
        dest_path = expand_path(destination)
        
        # Validate source exists
        if not os.path.exists(source_path):
            print_error(f"Source file not found: {source_path}")
            return False
            
        # Create parent directory if needed
        if create_parent:
            ensure_directory_exists(dest_path)
            
        # Check if destination already exists
        if os.path.exists(dest_path) or os.path.islink(dest_path):
            if os.path.islink(dest_path) and os.readlink(dest_path) == source_path:
                print_info(f"Symlink already exists: {dest_path} → {source_path}")
                return True
                
            if not self.force and self.interactive:
                if not get_user_confirmation(f"Replace existing file {dest_path}?"):
                    print_info(f"Skipping {dest_path}")
                    return False
                    
            # Backup existing file
            if not self.force and self.backup_manager and not self.dry_run:
                self.backup_manager.backup_file(dest_path)
                
            # Remove existing file
            if not self.dry_run:
                if os.path.islink(dest_path):
                    os.unlink(dest_path)
                elif os.path.isdir(dest_path):
                    import shutil
                    shutil.rmtree(dest_path)
                else:
                    os.remove(dest_path)
                    
        # Create symlink
        if self.dry_run:
            print_info(f"[DRY RUN] Would create symlink: {dest_path} → {source_path}")
        else:
            try:
                os.symlink(source_path, dest_path)
                print_success(f"Created symlink: {dest_path} → {source_path}")
                if description:
                    print_info(f"  Description: {description}")
                self.created_symlinks.append((source_path, dest_path))
                return True
            except Exception as e:
                print_error(f"Failed to create symlink {dest_path}: {e}")
                return False
                
        return True
        
    def create_symlinks_from_config(self, symlinks_config: List[Dict[str, Any]]) -> int:
        """Create multiple symlinks from configuration.
        
        Args:
            symlinks_config: List of symlink configurations
            
        Returns:
            Number of symlinks created successfully
        """
        success_count = 0
        
        for config in symlinks_config:
            source = config.get('source')
            destination = config.get('destination')
            
            if not source or not destination:
                print_error("Invalid symlink configuration: missing source or destination")
                continue
                
            # Check optional flag
            if config.get('optional', False):
                # Skip if optional and user doesn't confirm
                if self.interactive:
                    desc = config.get('description', source)
                    if not get_user_confirmation(f"Create symlink for {desc}?"):
                        continue
                        
            if self.create_symlink(
                source=source,
                destination=destination,
                create_parent=config.get('create_parent', False),
                description=config.get('description', '')
            ):
                success_count += 1
                
        return success_count
        
    def remove_symlink(self, destination: str) -> bool:
        """Remove a symlink if it exists.
        
        Args:
            destination: Path to symlink to remove
            
        Returns:
            True if removed successfully
        """
        dest_path = expand_path(destination)
        
        if not os.path.islink(dest_path):
            print_info(f"Not a symlink: {dest_path}")
            return False
            
        if self.dry_run:
            print_info(f"[DRY RUN] Would remove symlink: {dest_path}")
        else:
            try:
                os.unlink(dest_path)
                print_success(f"Removed symlink: {dest_path}")
                return True
            except Exception as e:
                print_error(f"Failed to remove symlink {dest_path}: {e}")
                return False
                
        return True
        
    def rollback(self) -> None:
        """Remove all created symlinks (for error recovery)."""
        print_info("Rolling back created symlinks...")
        for source, dest in reversed(self.created_symlinks):
            self.remove_symlink(dest)