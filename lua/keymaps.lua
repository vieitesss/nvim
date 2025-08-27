local keymap = vim.keymap.set
local s = { silent = true }

keymap("n", "<space>", "<Nop>")

-- movement
keymap("n", "j", function()
    return tonumber(vim.api.nvim_get_vvar("count")) > 0 and "j" or "gj"
end, { expr = true, silent = true })
keymap("n", "k", function()
    return tonumber(vim.api.nvim_get_vvar("count")) > 0 and "k" or "gk"
end, { expr = true, silent = true })
keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "<C-u>", "<C-u>zz")

--- save and quit
keymap("n", "<Leader>w", "<cmd>w!<CR>", s)
keymap("n", "<Leader>q", "<cmd>q<CR>", s)

-- tabs
keymap("n", "<Leader>te", "<cmd>tabnew<CR>", s)

--- split windows
keymap("n", "<Leader>_", "<cmd>vsplit<CR>", s)
keymap("n", "<Leader>-", "<cmd>split<CR>", s)

--- formatting
keymap("n", "<Leader>fo", ":lua vim.lsp.buf.format()<CR>", s)

-- copy and paste
keymap("v", "<Leader>p", '"_dP')
keymap("x", "y", [["+y]], s)

-- terminal
keymap("t", "<Esc>", "<C-\\><C-N>")

-- cd current dir
keymap("n", "<leader>cd", '<cmd>lua vim.fn.chdir(vim.fn.expand("%:p:h"))<CR>')

local opts = { noremap = true, silent = true }
keymap("n", "grd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
keymap("n", "<leader>dn", "<cmd>lua vim.diagnostic.jump({ count = 1 })<CR>", opts)
keymap("n", "<leader>dp", "<cmd>lua vim.diagnostic.jump({ count = -1 })<CR>", opts)

keymap("n", "<leader>ex", '<cmd>Ex %:p:h<CR>')
keymap("n", "<leader>ps", '<cmd>lua vim.pack.update()<CR>')
keymap("n", "<leader>gs", '<cmd>Git<CR>', opts)
keymap("n", "<leader>gp", '<cmd>Git push<CR>', opts)
keymap("n", "<leader>ff", '<cmd>FzfLua files<CR>')
keymap("n", "<leader>fg", '<cmd>FzfLua live_grep<CR>')
keymap("n", "<leader>fh", '<cmd>FzfLua help_tags<CR>')
keymap("n", "<leader>co", '<cmd>CommandExecute<CR>')
keymap("n", "<leader>cr", '<cmd>CommandExecuteLast<CR>')
keymap("i", "<S-Tab>", 'copilot#Accept("\\<Tab>")', { expr = true, replace_keycodes = false })
keymap("n", "<leader>m", '<cmd>lua require("miniharp").toggle_file()<CR>')
keymap("n", "<leader>l", '<cmd>lua require("miniharp").show_list()<CR>')
keymap("n", "<C-n>", require("miniharp").next)
keymap("n", "<C-p>", require("miniharp").prev)
