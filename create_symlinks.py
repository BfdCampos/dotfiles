import os
import shutil

def create_symlink(source, destination):
    if os.path.exists(destination):
        backup_dir = os.path.expanduser('~/dotfiles_backup')
        if not os.path.exists(backup_dir):
            os.mkdir(backup_dir)
        shutil.move(destination, os.path.join(backup_dir, os.path.basename(destination)))

    os.symlink(source, destination)

config_mapping = {
    'bashrc': '~/.bashrc',
    #'bash_profile': '~/.bash_profile',
    'zshrc': '~/.zshrc',
}

if __name__ == "__main__":
    for source, dest in config_mapping.items():
        src_path = os.path.expanduser(f'~/GitRepos/dotfiles/{source}')
        dest_path = os.path.expanduser(dest)
        create_symlink(src_path, dest_path)

