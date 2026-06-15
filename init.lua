-- Configs
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.wildoptions = "pum"
vim.opt.path:append("**")
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.list = true
vim.opt.listchars = "space:·,tab: ,eol:,trail:·"
vim.opt.colorcolumn = "80"
vim.opt.scrolloff = 8
vim.opt.hlsearch = false
vim.opt.guicursor = "a:block"
vim.opt.swapfile = false
vim.opt.undodir = vim.fn.stdpath("state") .. "/undo-dir"
vim.opt.undofile = true

-- Plugins
vim.cmd("packadd nvim.undotree")

vim.pack.add({
    "https://github.com/blazkowolf/gruber-darker.nvim",
    "https://github.com/stevearc/oil.nvim",
    "https://github.com/dmtrKovalenko/fff",
    "https://github.com/vieitesss/minifugit.nvim"
})

require("minifugit").setup()

require("oil").setup({
    columns = {
        "permissions",
        "size",
        "mtime"
    },
    constrain_cursor = "name",
    view_options = {
        show_hidden = true
    }
})

vim.g.fff = {
  lazy_sync = true,
  debug = { enabled = true, show_scores = true },
  layout = {
      width = 1,
      height = 0.5,
      anchor = "bottom"
  }
}


vim.cmd.colorscheme("gruber-darker")

-- Mappings
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { silent = true })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { silent = true })
vim.keymap.set("n", "<c-d>", "<c-d>zz", { silent = true })
vim.keymap.set("n", "<c-u>", "<c-u>zz", { silent = true })
vim.keymap.set('n', '<leader>ff', function() require('fff').find_files() end)
vim.keymap.set('n', '<leader>fg', function() require('fff').live_grep() end)
vim.keymap.set("v", "<leader>y", '"*y', { desc = "Paste to the clipboard" })

vim.keymap.set("n", "<leader>of", "<cmd>Oil<cr>", { silent = true, desc = "_O_pen _F_ile directory" } )
vim.keymap.set("n", "<leader>oc", "<cmd>Oil " .. vim.fn.getcwd() .. "<cr>", { silent = true, desc = "_O_pen _C_WD" } )
vim.keymap.set("n", "<leader>gs", "<cmd>MinifugitStatus<cr>", { silent = true, desc = "_G_it _S_tatus" } )

-- Autocmds
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'fff.nvim' and (kind == 'install' or kind == 'update') then
      if not ev.data.active then vim.cmd.packadd('fff.nvim') end
      require('fff.download').download_or_build_binary()
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    callback = function() vim.hl.hl_op() end,
    desc = "Highlight yanked text"
})

-- User commands
vim.api.nvim_create_user_command("Term", function(opts)
    vim.cmd("vsplit")
    if opts.args == "" then
        vim.cmd("terminal")
        return
    end

    local shell = vim.env.SHELL or vim.o.shell
    vim.cmd("terminal " .. vim.fn.shellescape(shell) .. " -ic " .. vim.fn.shellescape(opts.args))
end, {
    nargs = "*",
    complete = "shellcmd",
})
