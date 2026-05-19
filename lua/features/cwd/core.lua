local M = {}

M.index_dir = vim.fn.stdpath("data") .. "/cwd/"
vim.fn.mkdir(M.index_dir, "p")

-- URL-style encoding so any absolute path is a valid filename:
--   % -> %25   (must come first)
--   / -> %2F
---@param path string
---@return string
function M.encode(path)
    local sub, _ = path:gsub("%%", "%%25"):gsub("/", "%%2F")
    return sub
end

---@param name string
---@return string
function M.decode(name)
    -- order matters: decode %2F first, then %25
    local sub, _ = name:gsub("%%2F", "/"):gsub("%%25", "%%")
    return sub
end

---@param path string
---@return string
function M.normalize(path)
    path = vim.fn.fnamemodify(vim.fn.expand(path), ":p")
    if path ~= "/" then
        path = path:gsub("/+$", "")
    end

    local ok, resolved = pcall(vim.fn.resolve, path)
    if ok and resolved ~= "" then
        path = resolved
    end

    return path
end

---@param path string
---@return string
local function expand(path)
    return M.normalize(vim.fn.expand(path))
end

---@param path string
---@return boolean
function M.is_directory(path)
    return vim.fn.isdirectory(path) == 1
end

---@param path string
---@return boolean
local function is_git_repo(path)
    return M.is_directory(path .. "/.git")
        or vim.fn.filereadable(path .. "/.git") == 1
end

---@param path string
---@return string[]
local function first_level_directories(path)
    local dirs = {}
    if not M.is_directory(path) then
        return dirs
    end

    for _, child in ipairs(vim.fn.glob(path .. "/*", false, true)) do
        if M.is_directory(child) then
            table.insert(dirs, M.normalize(child))
        end
    end

    return dirs
end

---@param paths string[]
---@param seen table<string, boolean>
---@param candidate string?
local function add_unique(paths, seen, candidate)
    if not candidate or candidate == "" or not M.is_directory(candidate) then
        return
    end

    candidate = M.normalize(candidate)
    if seen[candidate] then
        return
    end

    seen[candidate] = true
    table.insert(paths, candidate)
end

---@class CwdConfig
---@field paths string[] Directories whose first-level children can be selected.
---@field include_home_git_repos boolean Include Git repositories directly under $HOME.

---@param config CwdConfig
---@return string[]
function M.list(config)
    local dirs = {}
    local seen = {}

    for _, configured_path in ipairs(config.paths) do
        for _, dir in ipairs(first_level_directories(expand(configured_path))) do
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

---@param cwd string
---@return string
function M.entry_path(cwd)
    return M.index_dir .. M.encode(cwd) .. ".cwd"
end

---@param dirs string[]
function M.refresh_index(dirs)
    vim.fn.delete(M.index_dir, "rf")
    vim.fn.mkdir(M.index_dir, "p")

    for _, dir in ipairs(dirs) do
        vim.fn.writefile({ dir }, M.entry_path(dir))
    end
end

---@param dir string
function M.track_access(dir)
    local ok, file_picker = pcall(require, "fff.file_picker")
    if ok and type(file_picker.track_access) == "function" then
        pcall(file_picker.track_access, M.entry_path(dir))
    end
end

---@class CwdPickerItem
---@field name string?
---@field relative_path string?

---@class CwdPickerContext
---@field cursor number
---@field selected_files table<string, boolean>?
---@field config { hl: table<string, string>? }

---@param picker_path string?
---@return string?
local function relative_path_to_dir(picker_path)
    if not picker_path or picker_path == "" then
        return nil
    end
    return M.decode(vim.fn.fnamemodify(picker_path, ":t:r"))
end

---@param item CwdPickerItem?
---@return string?
function M.item_to_dir(item)
    if not item then
        return nil
    end
    return relative_path_to_dir(item.relative_path or item.name)
end

---@param item CwdPickerItem
---@return string[]
function M.render_line(item)
    local dir = M.item_to_dir(item)
    return { dir and vim.fn.fnamemodify(dir, ":~") or "" }
end

---@param item CwdPickerItem
---@param ctx CwdPickerContext
---@param item_idx number
---@param buf number
---@param ns_id number
---@param line_idx number
---@param line_content string
function M.apply_highlights(
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

return M
