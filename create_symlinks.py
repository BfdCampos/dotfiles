import os
import shutil
import subprocess
import platform

# Terminal colors
RED = '\033[91m'
GREEN = '\033[92m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
RESET = '\033[0m'

def create_symlink(source, destination):
    print(f"{YELLOW}Creating symlink for {source}{RESET}")
    if os.path.exists(destination):
        print(f"{BLUE}Backup existing {destination} file{RESET}")
        backup_dir = os.path.expanduser('~/dotfiles_backup')
        if not os.path.exists(backup_dir):
            os.mkdir(backup_dir)
        shutil.move(destination, os.path.join(backup_dir, os.path.basename(destination)))
    os.symlink(source, destination)
    print(f"{GREEN}Symlink created for {source}{RESET}")

def install_neovim():
    print(f"{YELLOW}Detecting OS to install Neovim{RESET}")
    os_type = platform.system()
    if os_type == "Linux":
        print(f"{BLUE}Updating package list and installing Neovim on Linux{RESET}")
        subprocess.run(["sudo", "apt", "update"])
        subprocess.run(["sudo", "apt", "install", "neovim"])
    elif os_type == "Darwin":
        print(f"{BLUE}Installing Neovim on macOS{RESET}")
        subprocess.run(["brew", "install", "neovim"])
    else:
        print(f"{RED}Unsupported OS: {os_type}{RESET}")
        return

    print(f"{YELLOW}Setting up Neovim configuration{RESET}")
    nvim_config_dir = os.path.expanduser('~/.config/nvim')
    if not os.path.exists(nvim_config_dir):
        os.makedirs(nvim_config_dir)

    init_vim_source = os.path.expanduser('~/dotfiles/init.vim')
    init_vim_dest = os.path.expanduser('~/.config/nvim/init.vim')
    create_symlink(init_vim_source, init_vim_dest)

def install_ohmyzsh_plugins():
    print(f"{YELLOW}Installing Oh My Zsh plugins{RESET}")

    zsh_custom_dir = os.path.expanduser(os.environ.get('ZSH_CUSTOM', '~/.oh-my-zsh/custom'))

    # List of plugins and their git URLs
    plugins = {
        'zsh-autosuggestions': 'https://github.com/zsh-users/zsh-autosuggestions.git',
        'zsh-syntax-highlighting': 'https://github.com/zsh-users/zsh-syntax-highlighting.git'
    }

    # List of themes and their git URLs
    themes = {
        'powerlevel10k': 'https://github.com/romkatv/powerlevel10k.git'
    }

    # Install plugins
    for plugin, url in plugins.items():
        plugin_dir = f"{zsh_custom_dir}/plugins/{plugin}"
        if not os.path.exists(plugin_dir):
            print(f"{BLUE}Installing {plugin}{RESET}")
            subprocess.run(["git", "clone", url, plugin_dir])
            print(f"{GREEN}{plugin} installed{RESET}")
        else:
            print(f"{GREEN}{plugin} already exists{RESET}")

    # Install themes
    for theme, url in themes.items():
        theme_dir = f"{zsh_custom_dir}/themes/{theme}"
        if not os.path.exists(theme_dir):
            print(f"{BLUE}Installing {theme}{RESET}")
            subprocess.run(["git", "clone", "--depth=1", url, theme_dir])
            print(f"{GREEN}{theme} installed{RESET}")
        else:
            print(f"{GREEN}{theme} already exists{RESET}")


print(f"{YELLOW}=== Starting Automated Setup ==={RESET}")

config_mapping = {
    'bashrc': '~/.bashrc',
    'zshrc': '~/.zshrc',
    'p10k.zsh': '~/.p10k.zsh',
}

if __name__ == "__main__":
    for source, dest in config_mapping.items():
        src_path = os.path.expanduser(f'~/dotfiles/{source}')
        dest_path = os.path.expanduser(dest)
        create_symlink(src_path, dest_path)

    install_neovim()

    install_ohmyzsh_plugins()

    print(f"{GREEN}=== Setup Complete ==={RESET}")
