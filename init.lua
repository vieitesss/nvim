-- Configs
vim.opt.signcolumn = 'yes'
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
vim.opt.listchars = "space:·,tab: ,eol:,trail:·"
vim.opt.colorcolumn = "80"
vim.opt.scrolloff = 8
vim.opt.hlsearch = false
vim.opt.guicursor = "a:block"
vim.opt.swapfile = false
vim.opt.undodir = vim.fn.stdpath("state") .. "/undo-dir"
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

require('vim._core.ui2').enable({
    enable = true,
    msg = {
        targets = 'msg', -- 'cmd'|'msg'|'pager'
        msg = {
            height = 0.5,
        },
    },
})

-- Plugins
vim.pack.add({
    "https://github.com/mason-org/mason.nvim",
    -- local: gruber-lighter (see rtp below)
    "https://github.com/stevearc/oil.nvim",
    "https://github.com/dmtrKovalenko/fff",
    "https://github.com/vieitesss/minifugit.nvim",
    "https://github.com/vieitesss/miniharp.nvim",
    "https://github.com/vieitesss/command.nvim"
})

require("mason").setup()

local miniharp = require('miniharp')
miniharp.setup({
    notifications = false,
    ui = {
        position = 'top-right',
        show_hints = false,
        enter = false,
    },
})

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

vim.opt.rtp:prepend(vim.fn.expand("~/personal/gruber-lighter.nvim"))
vim.cmd.colorscheme("gruber-lighter")

-- Mappings
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { silent = true })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { silent = true })
vim.keymap.set("n", "<c-d>", "<c-d>zz", { silent = true })
vim.keymap.set("n", "<c-u>", "<c-u>zz", { silent = true })
vim.keymap.set("v", "<leader>y", '"*y', { desc = "Paste to the clipboard" })
vim.keymap.set("n", "<leader>fo", function() vim.lsp.buf.format() end, { desc = "_FO_rmat using LSP" })
vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, { desc = "_G_o to _D_efinition" })
-- -- fff
vim.keymap.set('n', '<leader>ff', function() require('fff').find_files() end)
vim.keymap.set('n', '<leader>fg', function() require('fff').live_grep() end)
-- -- oil
vim.keymap.set("n", "<leader>of", "<cmd>Oil<cr>", { silent = true, desc = "_O_pen _F_ile directory" })
vim.keymap.set("n", "<leader>oc", "<cmd>Oil " .. vim.fn.getcwd() .. "<cr>", { silent = true, desc = "_O_pen _C_WD" })
-- -- minifugit
vim.keymap.set("n", "<leader>gs", "<cmd>MinifugitStatus<cr>", { silent = true, desc = "_G_it _S_tatus" })
-- -- miniharp
vim.keymap.set('n', '<leader>m', miniharp.toggle_file, { desc = 'miniharp: toggle file mark' })
vim.keymap.set('n', '<leader>l', miniharp.show_list, { desc = 'miniharp: toggle marks list' })
vim.keymap.set('n', '<leader>L', miniharp.enter_list, { desc = 'miniharp: enter marks list' })
vim.keymap.set('n', '<C-j>', function() miniharp.go_to(1) end, { desc = 'miniharp: go to mark 1' })
vim.keymap.set('n', '<C-k>', function() miniharp.go_to(2) end, { desc = 'miniharp: go to mark 2' })
vim.keymap.set('n', '<C-l>', function() miniharp.go_to(3) end, { desc = 'miniharp: go to mark 3' })
-- -- command
vim.keymap.set('n', '<leader>ce', '<Plug>(CommandExecute)')
vim.keymap.set('n', '<leader>cl', '<Plug>(CommandExecuteLast)')
vim.keymap.set('x', '<leader>ce', '<Plug>(CommandExecuteSelection)')
vim.keymap.set('n', '<leader>cr', '<Plug>(CommandReopenTerminal)')


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

-- LSP
local lsps = {
    'rust-analyzer',
    'lua_ls',
}

for _, l in ipairs(lsps) do
    vim.lsp.enable(l)
end

vim.lsp.config('*', {
    capabilities = vim.lsp.protocol.make_client_capabilities()
})
