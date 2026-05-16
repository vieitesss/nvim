local M = {}

---@class CwdConfig
---@field paths string[] Directories whose first-level children can be selected.
---@field include_home_git_repos boolean Include Git repositories directly under $HOME.

---@class CwdSetupOptions
---@field paths string[]? Directories whose first-level children can be selected.
---@field include_home_git_repos boolean? Include Git repositories directly under $HOME.

---@class CwdPickerItem
---@field name string?
---@field relative_path string?

---@class CwdPickerContext
---@field cursor number
---@field selected_files table<string, boolean>?
---@field config { hl: table<string, string>? }

local cwd_dir = vim.fn.stdpath("data") .. "/cwd/"
vim.fn.mkdir(cwd_dir, "p")

---@type CwdConfig
local config = {
    paths = {},
    include_home_git_repos = true,
}

-- URL-style encoding so any absolute path is a valid filename:
--   % -> %25   (must come first)
--   / -> %2F
---@param path string
---@return string
local function encode(path)
    local sub, _ = path:gsub("%%", "%%25"):gsub("/", "%%2F")
    return sub
end

---@param name string
---@return string
local function decode(name)
    -- order matters: decode %2F first, then %25
    local sub, _ =  name:gsub("%%2F", "/"):gsub("%%25", "%%")
    return sub
end

---@param path string
---@return string
local function normalize(path)
    path = vim.fn.fnamemodify(path, ":p")
    if path ~= "/" then
        path = path:gsub("/+$", "")
    end
    return path
end

---@param path string
---@return string
local function expand(path)
    return normalize(vim.fn.expand(path))
end

---@param path string
---@return boolean
local function is_directory(path)
    return vim.fn.isdirectory(path) == 1
end

---@param path string
---@return boolean
local function is_git_repo(path)
    return is_directory(path .. "/.git")
        or vim.fn.filereadable(path .. "/.git") == 1
end

---@param paths string[]
---@param seen table<string, boolean>
---@param path string?
local function add_unique(paths, seen, path)
    if not path or path == "" or not is_directory(path) then
        return
    end

    path = normalize(path)
    if seen[path] then
        return
    end

    seen[path] = true
    table.insert(paths, path)
end

---@param path string
---@return string[]
local function first_level_directories(path)
    local dirs = {}
    if not is_directory(path) then
        return dirs
    end

    for _, child in ipairs(vim.fn.glob(path .. "/*", false, true)) do
        if is_directory(child) then
            table.insert(dirs, normalize(child))
        end
    end

    return dirs
end

---@return string[]
local function list()
    local dirs = {}
    local seen = {}

    for _, path in ipairs(config.paths) do
        for _, dir in ipairs(first_level_directories(expand(path))) do
            add_unique(dirs, seen, dir)
        end
    end

    if config.include_home_git_repos then
        for _, dir in ipairs(first_level_directories(vim.fn.expand("~"))) do
            if is_git_repo(dir) then
                add_unique(dirs, seen, dir)
            end
        end
    end

    table.sort(dirs)
    return dirs
end

---@param path string
---@return string
local function entry_path(path)
    return cwd_dir .. encode(path) .. ".cwd"
end

---@param dirs string[]
local function refresh_index(dirs)
    vim.fn.delete(cwd_dir, "rf")
    vim.fn.mkdir(cwd_dir, "p")

    for _, dir in ipairs(dirs) do
        vim.fn.writefile({ dir }, entry_path(dir))
    end
end

local cwd_renderer = {}

---@param path string?
---@return string?
local function relative_path_to_dir(path)
    if not path or path == "" then
        return nil
    end
    return decode(vim.fn.fnamemodify(path, ":t:r"))
end

---@param item CwdPickerItem?
---@return string?
local function item_to_dir(item)
    if not item then
        return nil
    end
    return relative_path_to_dir(item.relative_path or item.name)
end

---@param item CwdPickerItem
---@return string[]
function cwd_renderer.render_line(item)
    local dir = item_to_dir(item)
    return { dir and vim.fn.fnamemodify(dir, ":~") or "" }
end

---@param item CwdPickerItem
---@param ctx CwdPickerContext
---@param item_idx number
---@param buf number
---@param ns_id number
---@param line_idx number
---@param line_content string
function cwd_renderer.apply_highlights(
    item,
    ctx,
    item_idx,
    buf,
    ns_id,
    line_idx,
    line_content
)
    local selected = ctx.selected_files
        and item.relative_path
        and ctx.selected_files[item.relative_path]
    local hl = ctx.config.hl or {}
    local line_hl = item_idx == ctx.cursor and "Visual"
        or (selected and (hl.selected or "FFFSelected"))

    if line_hl then
        vim.api.nvim_buf_set_extmark(buf, ns_id, line_idx - 1, 0, {
            end_col = #line_content,
            hl_group = line_hl,
        })
    end
end

---@param path string
local function change_to(path)
    vim.cmd("cd " .. vim.fn.fnameescape(path))
    vim.notify("Cwd: " .. vim.fn.fnamemodify(path, ":~"))
end

---@return nil
function M.pick()
    local dirs = list()
    if #dirs == 0 then
        vim.notify("No cwd directories found")
        return
    end
    refresh_index(dirs)

    local ok, picker = pcall(require, "fff.picker_ui")
    if not ok then
        vim.notify("Could not load fff cwd picker", vim.log.levels.WARN)
        return
    end
    if picker.state.active then
        return
    end

    local original_select = picker.select
    local original_close = picker.close
    local restored = false

    ---@return nil
    local function restore()
        if restored then
            return
        end
        restored = true
        picker.select = original_select
        picker.close = original_close
    end

    ---@return string?
    local function selected_dir()
        local item = picker.state.filtered_items[picker.state.cursor]
        return item_to_dir(item)
    end

    picker.close = function(...)
        restore()
        return original_close(...)
    end

    picker.select = function()
        local dir = selected_dir()
        if not dir then
            return
        end
        restore()
        original_close()
        change_to(dir)
    end

    local opened, err = pcall(picker.open, {
        cwd = cwd_dir,
        title = "Change cwd",
        prompt = "Cwd > ",
        renderer = cwd_renderer,
        preview = { enabled = false },
        layout = { height = 0.35, width = 0.55 },
    })
    if not opened or not picker.state.active then
        restore()
        vim.notify(
            "Could not open fff cwd picker: " .. tostring(err),
            vim.log.levels.WARN
        )
    end
end

---@param opts CwdSetupOptions?
---@return nil
function M.setup(opts)
    opts = opts or {}
    if opts.paths ~= nil then
        config.paths = opts.paths
    end
    if opts.include_home_git_repos ~= nil then
        config.include_home_git_repos = opts.include_home_git_repos
    end

    vim.keymap.set(
        "n",
        "<C-p>",
        M.pick,
        { desc = "Cwd: change", silent = true }
    )
end

M.list = list
M.change_to = change_to

return M
