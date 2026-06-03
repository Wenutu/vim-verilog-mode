# vim-verilog-mode

Bring the power of Emacs' `verilog-mode` `AUTO` expansion features into Vim.

This plugin provides a seamless integration, allowing you to update Verilog `/* AUTO */` blocks without ever leaving your Vim editor. It works by calling Emacs in batch mode to perform the heavy lifting.

## Features

-   **On-demand Loading**: Verilog commands and mappings are installed only for buffers with `filetype=verilog` or `filetype=systemverilog`.
-   **Asynchronous by Default**: On modern Vim (with `+job`), Emacs runs in the background, so your UI stays responsive, even with large files.
-   **Synchronous Fallback**: Compatible with older Vim versions (like Vim 7) by automatically switching to a blocking mode.
-   **Verilog/SystemVerilog Runtime Support**: Includes built-in syntax highlighting and fast indentation scripts that follow your buffer-local Vim indentation settings.
-   **Simple and Flexible**: Comes with intuitive default key mappings (`ta`, `td`) and Ex commands.
-   **Highly Configurable**: Easily customize key mappings, Emacs executable path, and even load your own custom Emacs Lisp configuration files for project-specific settings.
-   **Robust Error Handling**: Provides clear feedback if Emacs fails or if configurations are missing.

## Installation

### vim-plug

```vim
Plug 'Wenutu/vim-verilog-mode'
```

For vim-plug filetype lazy loading:

```vim
Plug 'Wenutu/vim-verilog-mode', { 'for': ['verilog', 'systemverilog'] }
```

## Prerequisites

You must have **Emacs** installed and accessible in your system's `PATH`. The plugin also ships with a copy of `verilog-mode.el.gz`, so you don't need a separate installation of it unless you want to use a specific version.

## Usage

The plugin provides two primary modes of operation, available only in Verilog and SystemVerilog files (`filetype=verilog` or `filetype=systemverilog`).

The ftplugin does not override your tab or indentation options. The bundled
indent scripts use `shiftwidth()`, so set your preferred spacing in your Vim
configuration. For 4-space, no-tab Verilog editing:

```vim
autocmd FileType verilog,systemverilog setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4
```

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

You can customize the plugin by setting the following global variables in your `.vimrc`.

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
```

If `~/.emacs` exists, the plugin will load it with Emacs `-script`. You can use
it to customize `verilog-mode`, for example to use 4-space indentation:

```elisp
;; User customization for Verilog mode
(setq verilog-indent-level             4
      verilog-indent-level-module      4
      verilog-indent-level-declaration 4
      verilog-indent-level-behavioral  4
      verilog-indent-level-directive   1
      verilog-case-indent              4
      verilog-auto-newline             t
      verilog-auto-indent-on-newline   t
      verilog-tab-always-indent        t
      verilog-auto-endcomments         t
      verilog-minimum-comment-distance 40
      verilog-indent-begin-after-if    t
      verilog-auto-lineup              'declarations)
```

```vim
" --- Extra Mode Configuration ---
" A list of extra elisp files to load in "Extra Mode"
let g:verilog_mode_extra_elisp_scripts = ['~/.config/emacs/my-project-verilog-settings.el']

" --- Advanced ---
" Force synchronous (blocking) mode even on modern Vim
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

The asynchronous job control in modern Vim ensures that steps 2-4 happen in the background without interrupting your workflow.

## Testing

Run the built-in runtime smoke tests from the repository root:

```sh
vim -Nu NONE -i NONE -n -es -S tests/vimscript/verilog_runtime_smoke.vim
vim -Nu NONE -i NONE -n -es -S tests/vimscript/systemverilog_runtime_smoke.vim
```

The tests open the complex Verilog and SystemVerilog fixtures with this plugin
on `runtimepath`, then verify filetype detection, syntax groups, indentation
results, and the buffer-local AUTO command mappings.

To inspect the fixtures manually:

```sh
vim -Nu NONE -i NONE \
  --cmd 'set runtimepath^=/path/to/vim-verilog-mode' \
  --cmd 'syntax on' \
  --cmd 'filetype plugin indent on' \
  tests/fixtures/complex_verilog.v

vim -Nu NONE -i NONE \
  --cmd 'set runtimepath^=/path/to/vim-verilog-mode' \
  --cmd 'syntax on' \
  --cmd 'filetype plugin indent on' \
  tests/fixtures/complex_systemverilog.sv
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
