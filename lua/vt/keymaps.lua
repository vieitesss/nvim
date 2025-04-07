local keymap = vim.keymap.set
local s = { silent = true }

----- Normal -----
------------------

keymap("n", "j", function()
	return tonumber(vim.api.nvim_get_vvar("count")) > 0 and "j" or "gj"
end, { expr = true, silent = true })
keymap("n", "k", function()
	return tonumber(vim.api.nvim_get_vvar("count")) > 0 and "k" or "gk"
end, { expr = true, silent = true })

--- save and quit
keymap("n", "<Leader>w", "<cmd>w!<CR>", s)
keymap("n", "<Leader>q", "<cmd>q<CR>", s)

--- no highlight
keymap("n", "<Leader>no", "<cmd>noh<CR>", s)

--- window movements
-- keymap("n", "<C-H>", "<C-W>h", s)
-- keymap("n", "<C-J>", "<C-W>j", s)
-- keymap("n", "<C-K>", "<C-W>k", s)
-- keymap("n", "<C-L>", "<C-W>l", s)
--- resize horizontal
keymap("n", "<S-Up>", "<cmd>res -5<cr>", s)
keymap("n", "<S-Down>", "<cmd>res +5<cr>", s)
--- resize vertical
keymap("n", "<S-Left>", "<cmd>vert res -5<cr>", s)
keymap("n", "<S-Right>", "<cmd>vert res +5<cr>", s)

keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "<C-u>", "<C-u>zz")

keymap("n", "<space>", "<Nop>")

-- tabs
keymap("n", "<Leader>te", "<cmd>tabnew<CR>", s)
keymap("n", "<Leader>tp", "<cmd>tabp<CR>", s)
keymap("n", "<Leader>tn", "<cmd>tabn<CR>", s)

--- split windows
keymap("n", "<Leader>_", "<cmd>vsplit<CR>", s)
keymap("n", "<Leader>-", "<cmd>split<CR>", s)
keymap("n", "<Leader>=", "<C-w>=")

--- reload file
keymap("n", "<Leader>so", "<cmd>so %<CR>", s)
keymap("n", "<Leader><Leader>e", "<cmd>e<CR>", s)

--- formatting
keymap("n", "<Leader>fo", ":lua vim.lsp.buf.format()<CR>", s)
-- keymap("n", "<Leader>fo", "<cmd>lua require('conform').format()<CR>", s)

keymap("n", "<Leader>xx", "<cmd>luafile %<CR>", s)
----- Insert -----
------------------
--- quit
keymap({ "i", "x" }, "<C-c>", "<Esc>")

-- delete word backwards
keymap("i", "<M-BS>", "<C-w>")

----- Visual -----
------------------

--- quit
keymap("v", "<Leader>o", "<Esc>")

--- paste without losing previous paste
keymap("v", "<Leader>p", '"_dP')

--- move lines
keymap("v", "J", ":m '>+1<CR>gv=gv")
keymap("v", "K", ":m '<-2<CR>gv=gv")

--- copy
keymap("x", "y", [["+y]], s)

----- Terminal -----
--------------------
keymap("t", "<Esc>", "<C-\\><C-N>")
