-- Configs
vim.opt.signcolumn = 'yes'
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.wildoptions = "pum"
vim.opt.winborder = "rounded"
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
vim.cmd("packadd nvim.undotree");
vim.pack.add({
    "https://github.com/mason-org/mason.nvim",
    -- local: gruber-lighter (see rtp below)
    "https://github.com/stevearc/oil.nvim",
    "https://github.com/dmtrKovalenko/fff",
    "https://github.com/blazkowolf/gruber-darker.nvim",
    "https://github.com/vieitesss/gruber-lighter.nvim",
    "https://github.com/vieitesss/minifugit.nvim",
    "https://github.com/vieitesss/miniharp.nvim",
    "https://github.com/vieitesss/command.nvim"
})

require("mason").setup()

vim.g.minifugit = {
    preview = {
        show_metadata = false,
    },
    status = {
        open_in_tab = true,
    },
}

require("command").setup({
    ui = { terminal = { split = "right" } }
})

local miniharp = require('miniharp')
miniharp.setup({
    notifications = false,
    ui = {
        position = 'top-right',
        show_hints = false,
        enter = false,
        auto_hide = true,
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

-- vim.opt.rtp:prepend(vim.fn.expand("~/personal/gruber-lighter.nvim"))
local function apply_colorscheme()
    local name = vim.o.background == "dark" and "gruber-darker" or "gruber-lighter"
    if vim.g.colors_name ~= name then vim.cmd.colorscheme(name) end
end
apply_colorscheme()

-- Herdr may send an OSC 11 reply with its old colour before catching up (~100 ms).
local pending_osc11_queries = {}
vim.api.nvim_create_autocmd("TermResponse", {
    callback = function(ev)
        if not ev.data.sequence:match("^\27%]11;") then return end
        vim.schedule(apply_colorscheme)

        if #pending_osc11_queries > 0 then
            local query = table.remove(pending_osc11_queries, 1)
            query.pending = false
            return
        end

        vim.defer_fn(function()
            local query = { pending = true }
            table.insert(pending_osc11_queries, query)
            vim.api.nvim_ui_send("\27]11;?\7")
            vim.defer_fn(function()
                if not query.pending then return end
                query.pending = false
                for i, pending_query in ipairs(pending_osc11_queries) do
                    if pending_query == query then
                        table.remove(pending_osc11_queries, i)
                        break
                    end
                end
            end, 1000)
        end, 250)
    end,
})

-- Transparency: terminal (ghostty) owns the opacity; just stop painting backgrounds.
local function set_transparency()
    local transparent_groups = { 'Normal', 'NormalNC', 'NormalFloat', 'NormalSB' }
    local function apply_transparency()
        for _, g in ipairs(transparent_groups) do
            vim.cmd.highlight(g .. ' guibg=NONE')
        end
    end
    vim.opt.winblend = 12
    vim.opt.pumblend = 12
    apply_transparency()
    vim.api.nvim_create_autocmd('ColorScheme', { callback = apply_transparency })
end
set_transparency()

-- Mappings
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { silent = true })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { silent = true })
vim.keymap.set("n", "<c-d>", "<c-d>zz", { silent = true })
vim.keymap.set("n", "<c-u>", "<c-u>zz", { silent = true })
vim.keymap.set("v", "<leader>y", '"*y', { desc = "Paste to the clipboard" })
vim.keymap.set("n", "<leader>fo", function() vim.lsp.buf.format() end, { desc = "_FO_rmat using LSP" })
vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, { desc = "_G_o to _D_efinition" })
vim.keymap.set("i", "<C-j>", function() vim.lsp.completion.get() end)
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
vim.keymap.set('n', '<C-l>', function()
    local ns = vim.api.nvim_create_namespace('nvim.multicursor')
    if #vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, { limit = 1 }) > 0 then
        vim.cmd('nohlsearch | diffupdate')
        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
        vim.cmd('normal! \x0c')
        return
    end
    miniharp.go_to(3)
end, { desc = 'clear multicursors or miniharp mark 3' })
-- -- command
vim.keymap.set('n', '<leader>ce', '<Plug>(CommandExecute)')
vim.keymap.set('n', '<leader>cl', '<Plug>(CommandExecuteLast)')
vim.keymap.set('x', '<leader>ce', '<Plug>(CommandExecuteSelection)')
vim.keymap.set('n', '<leader>cr', '<Plug>(CommandReopenTerminal)')
vim.keymap.set('n', '<leader>cc', '<Plug>(CommandCycleTerminalSide)')


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

vim.api.nvim_create_autocmd("LspAttach", {
    pattern = { "*.rs", "*.lua" },
    callback = function(ev)
        vim.lsp.completion.enable(true, ev.data.client_id, 0)
    end,
    desc = "Enable completions for these filetypes"
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
