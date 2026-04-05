# Dotfiles Repository - AGENTS.md

## Overview
This document describes the structure and components of the neo-dots repository, providing guidance for AI agents working with this codebase.

## Repository Structure

### Core Components
- **install.sh**: Main installer script with support for macOS, Arch Linux (bare or on HyDE)
- **bootstrap.sh**: Dependency installation and shared detection functions (in scripts/)
- **patches/**: Directory containing post-installation scripts for different environments

### Stow Packages (Managed by GNU Stow)
These are the primary configuration directories that get symlinked into $HOME:

#### Base Packages (Always Available)
- `bat`: Configuration for bat (cat clone with syntax highlighting)
- `eza`: Configuration for eza (modern ls replacement)
- `ghostty`: Configuration for ghostty terminal emulator
- `lazygit`: Configuration for lazygit (terminal UI for git)
- `local`: Local user-specific configurations
- `nvim`: Neovim configuration
- `starship`: Starship prompt configuration
- `tmux`: Tmux terminal multiplexer configuration
- `zsh`: Zsh shell configuration

#### macOS-Specific
- `macos`: macOS-specific configurations and settings

#### Architecture-Specific (Arch Linux / CachyOS)
Selected based on detected desktop environment/window manager:
- `arch-common`: Base Arch Linux configurations
- `arch-hyde`: HyDE (Hyprland Development Environment) specific configurations
- `arch-niri`: Niri window manager specific configurations

### Package Management
- **Homebrew** (macOS): Managed via Brewfiles in `homebrew/` directory
- **Arch Packages** (Arch/CachyOS): Managed via package lists in `arch-pkgs/` directory

### Key Files
- `.gitconfig`: Git configuration template
- `.gitattributes`: Git attributes file
- `.gitignore`: Git ignore patterns

### Directory Details
- `arch-common/`: Common Arch Linux configurations (zsh, etc.)
- `arch-dank/`: Dank Material Shell configurations
- `arch-hyde/`: HyDE-specific configurations (starship, zsh, etc.)
- `arch-niri/`: Niri window manager configurations
- `arch-patches/`: Patch files for Arch-specific post-install modifications
- `arch-pkgs/`: Package lists for Arch installation (core.txt, aur.txt, work.txt, etc.)
- `bat/`: Bat configuration
- `eza/`: Eza configuration
- `ghostty/`: Ghostty terminal configuration
- `homebrew/`: Brewfile definitions for macOS package management
- `lazygit/`: Lazygit configuration
- `local/`: Local override configurations
- `macos/`: macOS-specific configurations
- `misc/`: Miscellaneous utilities and scripts - NOT TO BE USED OR INCLUDED ANYWHERE, ONLY KEPT FOR LEGACY REFERENCE
- `nvim/`: Neovim configuration (plugins, settings, etc.)
- `scripts/`: Helper scripts (bootstrap.sh, patches/)
- `scripts/bootstrap.sh`: Dependency installation and OS detection
- `scripts/patches/`: Post-installation scripts for:
  - `common.sh`: Generic patches
  - `hyde.sh`: HyDE-specific patches
  - `hyprland.sh`: Hyprland patches
  - `niri.sh`: Niri patches
  - `dms.sh`: Dank Material Shell patches
- `starship/`: Starship prompt configuration
- `tmux/`: Tmux configuration
- `zsh/`: Zsh configuration

## Development Commands

### Build/Lint/Test Commands
This repository primarily contains configuration files and shell scripts. There is no traditional build process, but the following validation commands are available:

#### Shell Script Validation
- **Syntax Check**: `bash -n script.sh` - Check syntax without executing
- **ShellCheck**: `shellcheck script.sh` - Lint shell scripts for common errors
- **Installer Test**: `./install.sh --dry-run` - Test installer without making changes
- **Dependency Check**: `./scripts/bootstrap.sh` - Check and install required dependencies

#### Configuration Validation
- **TOML Files** (Starship): Use online TOML validators or `toml-test` if available
- **JSON Files**: `jq . file.json > /dev/null` - Validate JSON syntax
- **YAML Files** (if any): `yamllint file.yaml` or similar validators

#### Testing Individual Components
Since this is a dotfiles repository, "testing" typically means:
1. **Stow Simulation**: `stow --simulate --no-folding -t $HOME -d . <package>` 
2. **Config Validation**: Check individual config files with their respective tools
3. **Installer Dry Run**: `./install.sh --dry-run --interactive` - See what would be installed
4. **Specific Task Testing**: Call individual functions from install.sh in isolation

Example testing a single function:
```bash
# Source install.sh to get function definitions
source install.sh --source-only
# Then call the function directly, e.g.:
detect_os
echo "OS: $OS"
```

## Code Style Guidelines

### Shell Scripting (bash/zsh)

#### Formatting
- **Indentation**: 2 spaces (no tabs)
- **Line Length**: Maximum 100 characters (prefer 80 for readability)
- **End of File**: Should end with a newline
- **Shebang**: `#!/usr/bin/env bash` for bash scripts, `#!/usr/bin/env zsh` for zsh

#### Imports/Sourcing
- **Source Guard**: Use `--source-only` flag when sourcing install.sh for function reuse
- **Path Variables**: Use `$DOTFILES_DIR` for absolute paths, never hardcode
- **ShellCheck Directives**: 
  - `# shellcheck source=path/to/file` for sourced files
  - `# shellcheck disable=SCxxxx` to disable specific checks when necessary
  - Prefer fixing issues over disabling checks

#### Types & Variables
- **Variable Naming**: 
  - Constants: UPPER_SNAKE_CASE
  - Variables: snake_case
  - Functions: snake_case
  - Local variables: Always declare with `local` inside functions
- **Types**: Bash is dynamically typed, but follow these conventions:
  - Arrays: Use `(element1 element2)` syntax
  - Associative arrays: Declare with `declare -A`
  - Booleans: Use true/false or 0/1 consistently
  - Numbers: Use arithmetic expansion `$(( ))` for calculations

#### Functions
- **Declaration**: Use `function_name() {` format (not `function function_name {`)
- **Parameters**: Access via `$1`, `$2`, etc. or `"$@"` for all
- **Documentation**: Include comment blocks describing purpose, parameters, return values
- **Error Handling**: 
  - Check return values: `command || { echo "Error"; return 1; }`
  - Use `set -euo pipefail` at top of scripts
  - Validate inputs early
  - Use `err()`, `warn()`, `ok()`, `log()` functions for consistent output

#### Control Structures
- **Conditionals**: 
  - Prefer `[[ ]]` over `[ ]` for bash-specific features
  - Quote variables: `[[ "$var" == "value" ]]`
  - Use `&&` and `||` for simple conditions when appropriate
- **Loops**:
  - Prefer `for item in "${array[@]}"` over indexed loops
  - Use `while IFS= read -r line` for reading files line by line
  - Always quote variables in loops

#### Error Handling
- **Exit Codes**: 
  - 0: Success
  - 1: General error
  - 2: Misuse of shell builtins
  - 126: Command found but not executable
  - 127: Command not found
  - 128: Fatal error signal
- **Error Messages**: 
  - Use `err()` function for errors (prints to stderr)
  - Use `warn()` for warnings
  - Use `ok()` for success messages
  - Use `log()` for informational messages
- **Cleanup**: Use `trap` for cleanup operations when necessary

### Configuration File Styles

#### TOML (Starship)
- **Sections**: Use clear, descriptive section headers
- **Comments**: Use `#` for comments, align with content when possible
- **Strings**: Use double quotes for strings requiring escaping, single quotes for literal strings
- **Numbers**: Use standard notation, no leading zeros
- **Booleans**: lowercase `true`/`false`

#### JSON (if present)
- **Indentation**: 2 spaces
- **Trailing Commas**: Never include trailing commas
- **Strings**: Always double-quoted
- **Comments**: JSON doesn't support comments; use separate documentation if needed

#### General Config Files
- **Consistency**: Match existing style in the file
- **Comments**: Explain non-obvious configurations
- **Sections**: Group related settings logically
- **Whitespace**: Use blank lines to separate logical sections

## Special Considerations for This Repository

### HyDE Awareness
When working with HyDE-related code:
- Always preserve HyDE-owned files and configurations
- Use backup functions before modifying files that HyDE manages
- Respect HyDE's configuration directories and CLI completions
- Follow the Starship mode logic (dotfiles|hyde|env)

### Portability
- Scripts should work on both bash and zsh when possible
- Avoid bash-specific features in files meant to be sourced by zsh
- Test on target platforms: macOS, Arch Linux, CachyOS

### Security
- Never hardcode credentials or tokens in configuration files
- Use environment variables or secure stores for secrets
- Validate all inputs, especially those that could affect file paths
- Use `sudo` only when absolutely necessary and with caution

## Maintenance Guidelines

### Adding New Configurations
1. Create new directory for your stow package
2. Add package name to appropriate arrays in install.sh
3. For OS-specific packages, update selection logic
4. Add package lists to homebrew/ or arch-pkgs/ if needed
5. Create post-installation patches in scripts/patches/ if required

### Making Changes
1. Test changes in isolation before integrating
2. Use dry-run modes extensively
3. Backup critical configurations before testing
4. Verify changes work across all supported platforms
5. Update documentation when changing interfaces

### File Organization
- Keep stow package directories focused and minimal
- Place architecture-specific files in appropriate arch-* directories
- Keep patches in scripts/patches/ with clear naming
- Avoid putting functional code in misc/ (legacy only)
