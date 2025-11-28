# Dotfiles

A modular, extensible dotfiles management system with support for symlinks, package installation, and cross-platform compatibility.

## Features

- 🔗 **Symlink Management**: Automatically create symlinks for your dotfiles with backup support
- 📦 **Package Installation**: Install packages across different platforms (macOS, Linux)
- 🔄 **Backup System**: Automatic backup of existing files before replacement
- 🎯 **Selective Installation**: Choose what to install with interactive prompts
- 🏃 **Dry Run Mode**: Preview changes before applying them
- 🔧 **Extensible**: Easy to add new dotfiles and packages via YAML configuration

## Quick Start

```bash
# Clone the repository
git clone https://github.com/BfdCampos/dotfiles.git
cd dotfiles

# Install Python dependencies
pip install -r requirements.txt

# Run interactive setup
./setup.py

# Or run non-interactive setup (accept all)
./setup.py --yes

# Preview changes without applying
./setup.py --dry-run
```

## Usage

```bash
# Full interactive setup
./setup.py

# Non-interactive mode (accept all prompts)
./setup.py --yes

# Preview mode (no changes made)
./setup.py --dry-run

# Only create symlinks
./setup.py --only-symlinks

# Only install packages
./setup.py --only-packages

# Force overwrite without backup
./setup.py --force

# Use custom configuration
./setup.py --config my-config.yaml
```

## Configuration

### Dotfiles Configuration (`config/dotfiles.yaml`)

Define which files to symlink:

```yaml
symlinks:
  - source: bashrc
    destination: ~/.bashrc
    description: "Bash configuration"
    
  - source: init.vim
    destination: ~/.config/nvim/init.vim
    description: "Neovim configuration"
    create_parent: true  # Create parent directories if needed
    optional: true       # Ask user before creating
```

### Packages Configuration (`config/packages.yaml`)

Define packages to install:

```yaml
packages:
  neovim:
    description: "Hyperextensible Vim-based text editor"
    optional: true
    installers:
      darwin:
        method: homebrew
        package: neovim
      linux:
        method: apt
        package: neovim
```

## Directory Structure

```
dotfiles/
├── config/              # Configuration files
│   ├── dotfiles.yaml   # Symlink definitions
│   └── packages.yaml   # Package definitions
├── lib/                # Core modules
│   ├── backup.py       # Backup management
│   ├── installers.py   # Package installation
│   ├── symlinks.py     # Symlink management
│   └── utils.py        # Utility functions
├── setup.py            # Main setup script
├── bashrc              # Bash configuration
├── zshrc               # Zsh configuration
├── init.vim            # Neovim configuration
└── ...                 # Other dotfiles
```

## Adding New Dotfiles

1. Add your dotfile to the repository
2. Edit `config/dotfiles.yaml`:
   ```yaml
   - source: my-config-file
     destination: ~/.config/myapp/config
     description: "My app configuration"
     create_parent: true
   ```
3. Run `./setup.py` to create the symlink

## Legacy

The original `create_symlinks.py` has been renamed to `create_symlinks.py.legacy` for reference. Use `setup.py` for all dotfile management.
