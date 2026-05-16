local keymap = vim.keymap.set
local s = { silent = true }

keymap("n", "<space>", "<Nop>")

-- movement
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "<C-u>", "<C-u>zz")

--- save and quit
keymap("n", "<Leader>w", "<cmd>w!<CR>", s)
keymap("n", "<Leader>q", "<cmd>q<CR>", s)

-- tabs
keymap("n", "<Leader>te", "<cmd>tabnew<CR>", s)
keymap("n", "<Leader>tn", "<cmd>tabn<CR>", s)
keymap("n", "<Leader>tp", "<cmd>tabp<CR>", s)

--- split windows
keymap("n", "<Leader>_", "<cmd>vsplit<CR>", s)
keymap("n", "<Leader>-", "<cmd>split<CR>", s)

-- copy and paste
keymap("v", "<Leader>p", '"_dP')
keymap("x", "y", [["+y]], s)

-- cd current dir
keymap("n", "<leader>cd", '<cmd>lua vim.fn.chdir(vim.fn.expand("%:p:h"))<CR>')

local ns = { noremap = true, silent = true }
local er = { expr = true, replace_keycodes = false }
keymap("n", "grd", "<cmd>lua vim.lsp.buf.definition()<CR>", ns)
keymap("n", "<leader>dn", "<cmd>lua vim.diagnostic.jump({count = 1})<CR>", ns)
keymap("n", "<leader>dp", "<cmd>lua vim.diagnostic.jump({count = -1})<CR>", ns)

keymap("n", "<leader>ex", "<cmd>Ex %:p:h<CR>")
keymap("n", "<leader>of", "<cmd>Oil<CR>")
keymap("n", "<leader>oc", function()
    require("oil").open(vim.fn.getcwd())
end)
keymap("n", "<leader>ps", require("packui").open)

local mf = require("minifugit")
local log = require("minifugit.log")

keymap("n", "<leader>gs", mf.status)
keymap("n", "<leader>l", log.open)

local function visual_selection()
    local mode = vim.fn.mode()
    local start_pos, end_pos, region_type

    if mode:match("^[vV\22]") then
        start_pos, end_pos, region_type = vim.fn.getpos("v"), vim.fn.getpos("."), mode
    else
        start_pos, end_pos, region_type = vim.fn.getpos("'<"), vim.fn.getpos("'>"), vim.fn.visualmode()
    end

    local ok, lines = pcall(vim.fn.getregion, start_pos, end_pos, { type = region_type })
    if not ok or not lines then return "" end
    return vim.trim(table.concat(lines, " "))
end

keymap("n", "<leader>ff", function() require("fff").find_files() end)
keymap("n", "<leader>fg", function() require("fff").live_grep() end)
keymap("x", "<leader>fg", function()
    local query = visual_selection()
    if query ~= "" then
        require("fff").live_grep({ query = query })
    end
end)
keymap("n", "<leader>ce", "<cmd>CommandExecute<CR>")
keymap("n", "<leader>cl", "<cmd>CommandExecuteLast<CR>")
keymap("n", "<leader>cr", "<cmd>CommandReopenTerminal<CR>")
keymap({ "x", "v" }, "<leader>ce", "<cmd>CommandExecuteSelection<CR>")
keymap("i", "<S-Tab>", 'copilot#Accept("\\<Tab>")', er)
keymap("n", "<leader>ma", require("miniharp").toggle_file)
keymap("n", "<leader>mc", require("miniharp").clear)
keymap("n", "<leader>l", require("miniharp").show_list)
keymap("n", "<leader>L", require("miniharp").enter_list)
keymap("n", "<C-j>", function()
    require("miniharp").go_to(1)
end)
keymap("n", "<C-k>", function()
    require("miniharp").go_to(2)
end)
keymap("n", "<C-l>", function()
    require("miniharp").go_to(3)
end)
-- keymap({ "n", "x" }, "<leader>gy", require("gh-permalink").yank)
