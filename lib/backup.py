"""Backup management for existing files."""

import os
import shutil
from datetime import datetime
from typing import Optional
from .utils import expand_path, ensure_directory_exists, print_info, print_warning


class BackupManager:
    """Manages backing up existing files before creating symlinks."""
    
    def __init__(self, backup_dir: str = "~/dotfiles_backup", 
                 timestamp_format: str = "%Y%m%d_%H%M%S"):
        """Initialize backup manager.
        
        Args:
            backup_dir: Directory to store backups
            timestamp_format: Format for timestamp in backup names
        """
        self.backup_dir = expand_path(backup_dir)
        self.timestamp_format = timestamp_format
        ensure_directory_exists(self.backup_dir)
        
    def backup_file(self, file_path: str) -> Optional[str]:
        """Backup a file if it exists.
        
        Args:
            file_path: Path to file to backup
            
        Returns:
            Path to backup file if backed up, None otherwise
        """
        file_path = expand_path(file_path)
        
        if not os.path.exists(file_path):
            return None
            
        if os.path.islink(file_path):
            print_warning(f"Skipping backup of symlink: {file_path}")
            return None
            
        timestamp = datetime.now().strftime(self.timestamp_format)
        basename = os.path.basename(file_path)
        backup_name = f"{basename}.{timestamp}"
        backup_path = os.path.join(self.backup_dir, backup_name)
        
        try:
            if os.path.isdir(file_path):
                shutil.copytree(file_path, backup_path)
            else:
                shutil.copy2(file_path, backup_path)
            
            print_info(f"Backed up {file_path} to {backup_path}")
            return backup_path
            
        except Exception as e:
            print_warning(f"Failed to backup {file_path}: {e}")
            return None
            
    def restore_backup(self, backup_path: str, original_path: str) -> bool:
        """Restore a file from backup.
        
        Args:
            backup_path: Path to backup file
            original_path: Path to restore to
            
        Returns:
            True if restored successfully
        """
        backup_path = expand_path(backup_path)
        original_path = expand_path(original_path)
        
        if not os.path.exists(backup_path):
            print_warning(f"Backup file not found: {backup_path}")
            return False
            
        try:
            # Remove existing file/directory if it exists
            if os.path.exists(original_path):
                if os.path.isdir(original_path):
                    shutil.rmtree(original_path)
                else:
                    os.remove(original_path)
                    
            # Restore from backup
            if os.path.isdir(backup_path):
                shutil.copytree(backup_path, original_path)
            else:
                shutil.copy2(backup_path, original_path)
                
            print_info(f"Restored {original_path} from {backup_path}")
            return True
            
        except Exception as e:
            print_warning(f"Failed to restore {original_path}: {e}")
            return False