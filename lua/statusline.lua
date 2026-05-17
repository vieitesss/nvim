local api = vim.api
local state = { path = true, branch = true, diag = {} }
local active, inactive = "%!v:lua.Statusline.active()", " %t%{&modified?'*':''}"

api.nvim_set_hl(0, "StatusLineDim", { link = "Comment" })

local function bufnr()
    local win = vim.g.statusline_winid
    if type(win) == "number" and api.nvim_win_is_valid(win) then
        return api.nvim_win_get_buf(win)
    end
    return api.nvim_get_current_buf()
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

local function path(buf)
    local dir = vim.fn.fnamemodify(api.nvim_buf_get_name(buf), ":~:.:h")
    if dir == "" or dir == "." then
        return ""
    end
    return state.path and ("%<" .. dir .. "/") or dim("/")
end

local function n(count, mark)
    count = tonumber(count) or 0
    return count > 0 and (" " .. mark .. count) or ""
end

local function git(buf)
    local g = vim.b[buf].gitsigns_status_dict
    if not g or not g.head or g.head == "" then
        return ""
    end
    return ("[ %s%s%s%s]"):format(
        state.branch and g.head or dim(""),
        n(g.added, "+"),
        n(g.changed, "~"),
        n(g.removed, "-")
    )
end

local function diagnostics(buf)
    local ok, s = pcall(vim.diagnostic.status, buf)
    s = ok and s or ""
    state.diag[buf] = s ~= "" and ("[" .. s .. "]") or ""
end

Statusline = {}
function Statusline.active()
    local buf = bufnr()
    return table.concat({
        "[",
        path(buf),
        "%t]%{&modified?'[+] ':' '}",
        git(buf),
        " ",
        state.diag[buf] or "",
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
api.nvim_create_autocmd({ "BufEnter", "DiagnosticChanged", "InsertLeave" }, {
    group = group,
    callback = function(args)
        if insert() then
            return
        end
        diagnostics(args.buf)
        if args.buf == api.nvim_get_current_buf() then
            redraw()
        end
    end,
})

api.nvim_create_autocmd(
    "User",
    { group = group, pattern = "GitSignsUpdate", callback = redraw }
)

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
