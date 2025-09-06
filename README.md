# vim-verilog-mode

Bring the power of Emacs' `verilog-mode` `AUTO` expansion features into Vim.

This plugin provides a seamless integration, allowing you to update Verilog `/* AUTO */` blocks without ever leaving your Vim editor. It works by intelligently calling a background Emacs process to perform the heavy lifting.

![Demo GIF (Placeholder)](https://user-images.githubusercontent.com/username/repo/demo.gif)
*(You can create a small demo gif and place it here)*

## Features

-   **Asynchronous by Default**: On modern Vim (with `+job`) and Neovim, Emacs runs in the background, so your UI never freezes, even with large files.
-   **Synchronous Fallback**: Fully compatible with older Vim versions (like Vim 7) by automatically switching to a blocking mode.
-   **Simple and Flexible**: Comes with intuitive default key mappings (`ta`, `td`) and Ex commands.
-   **Highly Configurable**: Easily customize key mappings, Emacs executable path, and even load your own custom Emacs Lisp configuration files for project-specific settings.
-   **Robust Error Handling**: Provides clear feedback if Emacs fails or if configurations are missing.

## Installation

Use your favorite plugin manager.

<details>
<summary><b>vim-plug</b></summary>

```vim
Plug 'Wenutu/vim-verilog-mode'
```

</details>

<details>
<summary><b>packer.nvim</b></summary>

```lua
use 'Wenutu/vim-verilog-mode'
```

</details>

<details>
<summary><b>dein.vim</b></summary>

```vim
call dein#add('Wenutu/vim-verilog-mode')
```

</details>

<details>
<summary><b>Pathogen</b></summary>

```bash
git clone https://github.com/Wenutu/vim-verilog-mode.git ~/.vim/bundle/vim-verilog-mode
```

</details>

## Prerequisites

You must have **Emacs** installed and accessible in your system's `PATH`. The plugin also ships with a copy of `verilog-mode.el.gz`, so you don't need a separate installation of it unless you want to use a specific version.

## Usage

The plugin provides two primary modes of operation, available only in Verilog files (`filetype=verilog`).

### Default Mode

This mode is for standard `AUTO` expansion. It loads your `~/.emacs` configuration and the core `verilog-mode.el` script.

-   **Add/Update AUTOs**:
    -   Press `ta` in Normal mode.
    -   Run the command `:VerilogAutoAdd`.
-   **Delete AUTOs**:
    -   Press `td` in Normal mode.
    -   Run the command `:VerilogAutoDelete`.

### Extra Mode

This mode is for when you need to load project-specific or custom Emacs Lisp configurations (e.g., for special indentation rules). It loads everything from the Default Mode, plus any scripts you specify in the `g:verilog_mode_extra_elisp_scripts` variable.

-   **Add/Update AUTOs (with extra config)**:
    -   Press `tA` in Normal mode.
    -   Run the command `:VerilogAutoAddExtra`.
-   **Delete AUTOs (with extra config)**:
    -   Press `tD` in Normal mode.
    -   Run the command `:VerilogAutoDeleteExtra`.

## Configuration

You can customize the plugin by setting the following global variables in your `.vimrc` or `init.vim`.

```vim
" --- Basic Key Mappings ---
" Change the default mode keys
let g:verilog_mode_map_auto_add = '<Leader>va'
let g:verilog_mode_map_auto_delete = '<Leader>vd'

" Change the extra mode keys
let g:verilog_mode_map_auto_add_extra = '<Leader>vA'
let g:verilog_mode_map_auto_delete_extra = '<Leader>vD'

" --- Paths ---
" Specify a different Emacs executable
" let g:verilog_mode_emacs_executable = '/usr/local/bin/emacs'

" Use a custom verilog-mode.el file instead of the bundled one
" let g:verilog_mode_elisp_script_path = '~/path/to/your/verilog-mode.el'

" --- Extra Mode Configuration ---
" A list of extra elisp files to load in "Extra Mode"
let g:verilog_mode_extra_elisp_scripts = ['~/.config/emacs/my-project-verilog-settings.el']

" --- Advanced ---
" Force synchronous (blocking) mode even on modern Vim/Neovim
" Useful for debugging or if async behavior is unstable in your environment
" let g:verilog_mode_force_sync = 1
```

For more details, see the built-in documentation with `:help verilog-mode`.

## How It Works

1.  When a command is triggered, the plugin saves the current buffer's content to a temporary file.
2.  It spawns an Emacs process in batch mode (`-batch`), telling it to load `verilog-mode.el` and run the appropriate function (`verilog-batch-auto` or `verilog-batch-delete-auto`) on the temporary file.
3.  Emacs modifies the temporary file in place.
4.  The plugin reads the modified content from the temporary file and updates the Vim buffer.
5.  The temporary file is deleted.

The asynchronous job control in Vim/Neovim ensures that steps 2-4 happen in the background without interrupting your workflow.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.