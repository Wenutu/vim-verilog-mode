# vim-verilog-mode

Leverages the power of Emacs' verilog-mode for AUTO expansion directly within Vim.

This plugin acts as a lightweight bridge, calling an external Emacs process in the background to perform the heavy lifting of parsing your Verilog files and inserting `/* AUTO */` blocks, providing the best of both worlds.

## Features

- **Seamless Integration**: Use Emacs's robust `verilog-mode` without ever leaving Vim.
- **Asynchronous by Default**: Runs Emacs in the background on Vim 8+ and Neovim, keeping your editor responsive.
- **Vim 7 Compatible**: Includes a synchronous (blocking) fallback for older Vim versions.
- **Customizable**: Easily change default key mappings and the path to the Emacs executable.
- **Safety Switch**: Provides an option to force synchronous execution for Vim versions with unstable async support.
- **GUI Support**: Adds convenient menu items in gVim.
- **Lightweight and Robust**: Minimal code, self-contained, and designed to be highly reliable.

## Requirements

- **Emacs**: Must be installed and accessible in your system's `PATH`.
- Vim 7, Vim 8, or Neovim.

## Installation

Install using your favorite plugin manager.

**vim-plug**
```vim
Plug 'Wenutu/vim-verilog-mode'
```

**Vundle**
```vim
Plugin 'Wenutu/vim-verilog-mode'
```

**Pathogen**
```bash
git clone https://github.com/Wenutu/vim-verilog-mode.git ~/.vim/bundle/vim-verilog-mode
```

**Manual Installation**
Copy the plugin's directories (`autoload`, `ftplugin`, etc.) into your `~/.vim/` directory.

## Usage

The plugin provides functionality for both adding and deleting `AUTO` blocks. These actions are only mapped in Verilog buffers (`filetype=verilog`).

- **Add/Update AUTOs**:
  - Default mapping: `ta`
  - Command: `:VerilogAutoAdd`

- **Delete AUTOs**:
  - Default mapping: `td`
  - Command: `:VerilogAutoDelete`

## Configuration

You can customize the plugin by setting the following global variables in your `.vimrc` or `init.vim`.

#### Key Mappings

Change the default `ta` and `td` mappings.

```vim
" Example: Map to <Leader>a and <Leader>d
let g:verilog_mode_map_auto_add = '<Leader>a'
let g:verilog_mode_map_auto_delete = '<Leader>d'
```

#### Emacs Executable

Specify a custom path for the Emacs executable if it's not in your system `PATH`.

```vim
" Example:
let g:verilog_mode_emacs_executable = '/usr/local/bin/emacs'
```

#### Force Synchronous Mode (Troubleshooting)

If you experience issues with the asynchronous execution (e.g., empty errors, freezes) on your specific Vim version, you can force the plugin to use the stable, blocking mode.

```vim
" Set to 1 to always use the blocking (Vim 7) mode.
let g:verilog_mode_force_sync = 1
```

## License

MIT