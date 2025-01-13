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
keymap("n", "<Leader>w", ":w!<CR>", s)
keymap("n", "<Leader>q", ":q<CR>", s)

--- no highlight
keymap("n", "<Leader>no", ":noh<CR>", s)

--- window movements
keymap("n", "<Leader>H", ":wincmd H<CR>", s)
keymap("n", "<Leader>J", ":wincmd J<CR>", s)
keymap("n", "<Leader>K", ":wincmd K<CR>", s)
keymap("n", "<Leader>L", ":wincmd L<CR>", s)
keymap("n", "<Leader>m", ":wincmd o<CR>", s)

keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "<C-u>", "<C-u>zz")

keymap("n", "]<space>", "o<Esc>0Dk")
keymap("n", "[<space>", "O<Esc>0Dj")
keymap("n", "<space>", "<Nop>")

-- tabs
keymap("n", "<Leader>te", ":tabnew<CR>", s)
keymap("n", "<Leader>tp", ":tabp<CR>", s)
keymap("n", "<Leader>tn", ":tabn<CR>", s)

--- split windows
keymap("n", "<Leader>_", ":vsplit<CR>", s)
keymap("n", "<Leader>-", ":split<CR>", s)
keymap("n", "<Leader>=", "<C-w>=")

--- reload file
keymap("n", "<Leader>so", ":so %<CR>", s)
keymap("n", "<Leader><Leader>e", ":e<CR>", s)

--- formatting
keymap("n", "<Leader>fo", ":lua vim.lsp.buf.format()<CR>", s)

--- pdfviewer
keymap("n", "<Leader>pdf", ":lua OPENPDFVIEWER()<CR>", s)

-- quickfix
keymap("n", "<Leader>b", "<cmd>make<CR>", s)
keymap("n", "<C-q>", "<cmd>copen<CR>", s)
keymap("n", "]q", "<cmd>cn<CR>", s)
keymap("n", "[q", "<cmd>cp<CR>", s)

----- Insert -----
------------------
--- quit
keymap("i", "<C-c>", "<Esc>")

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
keymap("x", "<C-c>", [["+y]], s)
