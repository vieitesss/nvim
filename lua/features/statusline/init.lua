local api = vim.api
local state = { path = true, branch = true, diag = {}, git = {} }
local active, inactive = "%!v:lua.Statusline.active()", " %t%{&modified?'*':''}"

api.nvim_set_hl(0, "StatusLineDim", { link = "Comment" })

local function buf()
    local win = vim.g.statusline_winid
    return type(win) == "number"
            and api.nvim_win_is_valid(win)
            and api.nvim_win_get_buf(win)
        or api.nvim_get_current_buf()
end

local function dim(s)
    return "%#StatusLineDim#" .. s .. "%*"
end

local function insert()
    return api.nvim_get_mode().mode:match("^[iR]") ~= nil
end

local function redraw()
    if not insert() then
        vim.cmd.redrawstatus()
    end
end

local function count(n, sign)
    n = tonumber(n) or 0
    return n > 0 and (" " .. sign .. n) or ""
end

local function path(b)
    local dir = vim.fn.fnamemodify(api.nvim_buf_get_name(b), ":~:.:h")
    return (dir == "" or dir == ".") and ""
        or (state.path and ("%<" .. dir .. "/") or dim("/"))
end

local function refresh_git(b)
    local ok, git = pcall(require, "minifugit.git")
    if not ok then
        return
    end
    local branch_ok, head = pcall(git.branch)
    local counts_ok, c, err =
        pcall(git.file_change_counts, api.nvim_buf_get_name(b))
    if not branch_ok or head == "" or not counts_ok or err then
        state.git[b] = ""
        return
    end

    state.git[b] = ("[ %s%s%s%s]"):format(
        state.branch and head or dim(""),
        count(c.added, "+"),
        count(c.modified, "~"),
        count(c.deleted, "-")
    )
end

local function refresh_diag(b)
    local ok, s = pcall(vim.diagnostic.status, b)
    s = ok and s or ""
    state.diag[b] = s ~= "" and ("[" .. s .. "]") or ""
end

Statusline = {}

function Statusline.active()
    local b = buf()
    return table.concat({
        "[",
        path(b),
        "%t]%{&modified?'[+] ':' '}",
        state.git[b] or "",
        " ",
        state.diag[b] or "",
        "%=",
        "%y [%P %l:%c]",
    })
end

function Statusline.inactive()
    return inactive
end

function Statusline.toggle_path()
    state.path = not state.path
    redraw()
end

function Statusline.toggle_branch()
    state.branch = not state.branch
    refresh_git(api.nvim_get_current_buf())
    redraw()
end

vim.keymap.set(
    "n",
    "<leader>sp",
    Statusline.toggle_path,
    { desc = "Toggle statusline path" }
)

vim.keymap.set(
    "n",
    "<leader>sb",
    Statusline.toggle_branch,
    { desc = "Toggle statusline git branch" }
)

local group = api.nvim_create_augroup("Statusline", { clear = true })
api.nvim_create_autocmd(
    { "BufEnter", "BufWritePost", "TextChanged", "InsertLeave" },
    {
        group = group,
        callback = function(a)
            if not insert() then
                refresh_git(a.buf)
                redraw()
            end
        end,
    }
)

api.nvim_create_autocmd({ "BufEnter", "DiagnosticChanged", "InsertLeave" }, {
    group = group,
    callback = function(a)
        if not insert() then
            refresh_diag(a.buf)
            redraw()
        end
    end,
})

api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group = group,
    callback = function()
        if
            vim.bo.buftype == ""
            and api.nvim_win_get_config(0).relative == ""
        then
            vim.wo.statusline = active
        end
    end,
})

api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
    group = group,
    callback = function()
        if
            vim.bo.buftype == ""
            and api.nvim_win_get_config(0).relative == ""
        then
            vim.wo.statusline = inactive
        end
    end,
})
