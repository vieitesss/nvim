local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "

vim.keymap.set("n", "<leader>ps", "<cmd>lua require('lazy').sync()<cr>", { silent = true })

return require("lazy").setup({
    spec = LAZY_PLUGIN_SPEC,
    defaults = {
        lazy = true,
        version = false
    },
    install = {
        colorscheme = { "rose-pine", "gruvbox", "kanagawa", "default" }
    },
    checker = { enabled = true, notify = false },
    change_detection = { notify = false }
})
