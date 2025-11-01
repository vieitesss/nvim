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

--- split windows
keymap("n", "<Leader>_", "<cmd>vsplit<CR>", s)
keymap("n", "<Leader>-", "<cmd>split<CR>", s)

-- copy and paste
keymap("v", "<Leader>p", '"_dP')
keymap("x", "y", [["+y]], s)

-- terminal
keymap("t", "<Esc>", "<C-\\><C-N>")

-- cd current dir
keymap("n", "<leader>cd", '<cmd>lua vim.fn.chdir(vim.fn.expand("%:p:h"))<CR>')

local ns = { noremap = true, silent = true }
local er = { expr = true, replace_keycodes = false }
keymap("n", "grd", "<cmd>lua vim.lsp.buf.definition()<CR>", ns)
keymap("n", "<leader>dn", "<cmd>lua vim.diagnostic.jump({count = 1})<CR>", ns)
keymap("n", "<leader>dp", "<cmd>lua vim.diagnostic.jump({count = -1})<CR>", ns)

keymap("n", "<leader>ex", "<cmd>Ex %:p:h<CR>")
keymap("n", "<leader>ps", "<cmd>lua vim.pack.update()<CR>")
keymap("n", "<leader>gs", "<cmd>Git<CR>", ns)
keymap("n", "<leader>gp", "<cmd>Git push<CR>", ns)
keymap("n", "<leader>ff", "<cmd>FzfLua files<CR>")
keymap("n", "<leader>fg", "<cmd>FzfLua grep_project<CR>")
keymap("n", "<leader>fl", "<cmd>FzfLua grep_last<CR>")
keymap("n", "<leader>fh", "<cmd>FzfLua help_tags<CR>")
keymap("n", "<leader>co", "<cmd>CommandExecute<CR>")
keymap("n", "<leader>cr", "<cmd>CommandExecuteLast<CR>")
keymap("i", "<S-Tab>", 'copilot#Accept("\\<Tab>")', er)
keymap("n", "<leader>ma", require("miniharp").toggle_file)
keymap("n", "<leader>mc", require("miniharp").clear)
keymap("n", "<leader>l", require("miniharp").show_list)
keymap("n", "<C-n>", require("miniharp").next)
keymap("n", "<C-p>", require("miniharp").prev)
keymap({ "n", "x" }, "<leader>gy", require("gh-permalink").yank)
keymap("n", "<leader>so", function()
    require("fzf-lua").files({
        actions = {
            ["default"] = function(selected)
                local file = selected[1]
                local rel_path = vim.fn.fnamemodify(file, ":.")

                rel_path = rel_path:gsub(" ", "\\ ")
                if not rel_path:match("^%.?/") then
                    rel_path = "./" .. rel_path
                end

                vim.api.nvim_put({ rel_path }, "l", true, false)
            end,
        },
    })
end)
