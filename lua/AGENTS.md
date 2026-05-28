# Modules' specifications

## RULES

- Read carefully, you have to ALWAYS pay attention to any word like MUST, NEVER, NOT, ALWAYS, and do what is said in those sentences.

This directory contains the main files that handle all the Neovim configuration. It's composed by the following modules:

1. Config-scoped modules:

- `autocmds.lua`: with global autocmds
- `configs.lua`: with global configuration options
- `keymaps.lua`: with all the keymaps for the installed plugins from `plugins.lua`
- `lsp.lua`: with the list of installed LSPs
- `plugins.lua`: with the installed plugins and specific configurations

2. Plugin-like modules:

- `packui.lua`: UI for managing installed plugins
- `sessions.lua`: UI for managing "tmux-like sessions", based on the working directory
- `statusline.lua`: custom status line
- `term.lua`: let's you create terminal buffers (1-5) and switch between them
- `umbraline.lua`: custom colorscheme

The plugin-like modules MUST:
- Be ALWAYS treated as independent modules. None of them should know anything about the others.
- Be written with production-ready Lua code. Look for simplicity. Do NOT abstract too much. ALWAYS use annotations (e.g. @param, @return, ...)

## term.lua

This module allows the user to create terminal buffers, with the possibility to create up to 5 different terminal buffers that will be handled by the module. The processes running on each buffer keep running even when hiding the terminals.
