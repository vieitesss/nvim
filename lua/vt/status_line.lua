local modes = {
    ["n"]  = "NORMAL",
    ["no"] = "NORMAL",
    ["v"]  = "VISUAL",
    ["V"]  = "VISUAL LINE",
    ["^V"] = "VISUAL BLOCK",
    ["s"]  = "SELECT",
    ["S"]  = "SELECT LINE",
    ["^S"] = "SELECT BLOCK",
    ["i"]  = "INSERT",
    ["ic"] = "INSERT",
    ["R"]  = "REPLACE",
    ["Rv"] = "VISUAL REPLACE",
    ["c"]  = "COMMAND",
    ["cv"] = "VIM EX",
    ["ce"] = "EX",
    ["r"]  = "PROMPT",
    ["rm"] = "MOAR",
    ["r?"] = "CONFIRM",
    ["!"]  = "SHELL",
    ["t"]  = "TERMINAL",
}

local function filepath()
    local fpath = vim.fn.fnamemodify(vim.fn.expand "%", ":~:.:h")
    if fpath == "" or fpath == "." then
        return ""
    end

    return string.format("%%<%s/", fpath)
end

local function abbreviate(name)
    local s = name:gsub("[-_]", " ")
    s = s:gsub("(%l)(%u)", "%1 %2")

    local parts = {}
    for word in s:gmatch("%S+") do
        parts[#parts + 1] = word
    end
    local letters = {}
    for _, w in ipairs(parts) do
        letters[#letters + 1] = w:sub(1, 2):lower()
    end
    return table.concat(letters, ".")
end

local function filename()
    local fname = vim.fn.expand "%:t"
    if fname == "" then
        return ""
    end
    if fname:len() > 15 then
        return abbreviate(fname) .. "." .. (vim.fn.expand "%:e")
    end
    return fname
end

local function filetype()
    return string.format("[%s]", vim.bo.filetype)
end

local function lineinfo()
    if vim.bo.filetype == "alpha" then
        return ""
    end
    return "[%P  %l:%c]"
end

local function shorten_branch(branch)
    if branch:len() < 15 then
        return branch
    end

    local prefix, rest = branch:match("^([^/]+)/(.+)$")
    if prefix then
        return prefix .. "/" .. abbreviate(rest)
    end

    return abbreviate(branch)
end

local function vcs()
    local git_info = vim.b.gitsigns_status_dict
    if not git_info or git_info.head == "" then
        return ""
    end
    local head = shorten_branch(git_info.head)
    local added = git_info.added and (" +" .. git_info.added) or ""
    local changed = git_info.changed and (" ~" .. git_info.changed) or ""
    local removed = git_info.removed and (" -" .. git_info.removed) or ""
    if git_info.added == 0 then
        added = ""
    end
    if git_info.changed == 0 then
        changed = ""
    end
    if git_info.removed == 0 then
        removed = ""
    end
    return table.concat {
        "[",
        " ",
        head,
        added,
        changed,
        removed,
        "]",
    }
end

Statusline = {}

Statusline.active = function()
    return table.concat {
        "[", filepath(), filename(), "] ",
        vcs(),
        "%=",
        filetype(),
        " ",
        lineinfo(),
    }
end

function Statusline.inactive()
    return " %t"
end

vim.api.nvim_exec([[
  augroup Statusline
  au!
  au WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline.active()
  au WinLeave,BufLeave * setlocal statusline=%!v:lua.Statusline.inactive()
  augroup END
]], false)
