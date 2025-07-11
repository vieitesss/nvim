local opt = vim.opt

-- General
vim.api.nvim_command("filetype plugin indent on")
opt.guicursor = "i:block"
-- opt.showcmdloc = "statusline"
-- opt.showmode = false
opt.colorcolumn = "80"
opt.signcolumn = "yes:1"
opt.termguicolors = true
opt.ignorecase = true
opt.conceallevel = 2

-- Indent
opt.autoindent = true
opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.shiftround = true
opt.listchars = "tab: ,multispace:|   ,eol:󰌑"
opt.hlsearch = false
opt.list = true
-- vim.cmd("set list")

-- Cmd line
-- opt.cmdheight = 0

-- Numbers
opt.number = true
opt.relativenumber = true
opt.numberwidth = 2

-- Lines
opt.wrap = false

-- Lines to edges

-- Cursor
opt.cursorline = true
opt.ruler = true
opt.scrolloff = 8

-- Words substitution
opt.inccommand = "nosplit"

-- Mouse
opt.mouse = "a"

-- Read files always
opt.autoread = true

-- Syntax
opt.syntax = "ON"

-- Time to complete key code sequence
opt.ttimeoutlen = 5

-- Hidden
opt.hidden = true

-- Undofile
opt.undodir = os.getenv('HOME') .. '/.vim/undodir'
opt.undofile = true

-- Disable netrw
-- vim.g.loaded_netrw = 0
