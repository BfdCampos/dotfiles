import os
import shutil
import subprocess
import platform

def create_symlink(source, destination):
    if os.path.exists(destination):
        backup_dir = os.path.expanduser('~/dotfiles_backup')
        if not os.path.exists(backup_dir):
            os.mkdir(backup_dir)
        shutil.move(destination, os.path.join(backup_dir, os.path.basename(destination)))

    os.symlink(source, destination)

def install_neovim():
    os_type = platform.system()
    if os_type == "Linux":
        subprocess.run(["sudo", "apt", "update"])
        subprocess.run(["sudo", "apt", "install", "neovim"])
    elif os_type == "Darwin":
        subprocess.run(["brew", "install", "neovim"])
    else:
        print(f"Unsupported OS: {os_type}")
        return

    nvim_config_dir = os.path.expanduser('~/.config/nvim')
    if not os.path.exists(nvim_config_dir):
        os.makedirs(nvim_config_dir)

    init_vim_source = os.path.expanduser('~/dotfiles/init.vim')
    init_vim_dest = os.path.expanduser('~/.config/nvim/init.vim')
    create_symlink(init_vim_source, init_vim_dest)

config_mapping = {
    'bashrc': '~/.bashrc',
    'zshrc': '~/.zshrc',
    'p10k.zsh': '~/.p10k.zsh',
    'zsh_history': '~/.zsh_history',
}

if __name__ == "__main__":
    for source, dest in config_mapping.items():
        src_path = os.path.expanduser(f'~/dotfiles/{source}')
        dest_path = os.path.expanduser(dest)
        create_symlink(src_path, dest_path)

