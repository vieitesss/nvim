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
local session_dir = vim.fn.stdpath("data") .. "/cwd-sessions/"
vim.fn.mkdir(cwd_dir, "p")
vim.fn.mkdir(session_dir, "p")

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
    local sub, _ = name:gsub("%%2F", "/"):gsub("%%25", "%%")
    return sub
end

---@param path string
---@return string
local function normalize(path)
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

---@param cwd string
---@return string
local function session_path(cwd)
    return session_dir .. encode(normalize(cwd)) .. ".json"
end

---@param f function
---@return boolean, any
local function safe(f)
    return pcall(f)
end

---@param buf number
---@param opt string
---@return any
local function buf_option(buf, opt)
    local ok, value = safe(function()
        return vim.api.nvim_get_option_value(opt, { buf = buf })
    end)
    return ok and value or nil
end

---@param buf number
---@return boolean
local function is_empty_buffer(buf)
    return vim.api.nvim_buf_is_valid(buf)
        and buf_option(buf, "buftype") == ""
        and buf_option(buf, "modified") ~= true
        and vim.api.nvim_buf_get_name(buf) == ""
        and vim.api.nvim_buf_line_count(buf) == 1
        and (vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or "") == ""
end

---@param buf number
---@return string?
local function real_file_path(buf)
    if
        not vim.api.nvim_buf_is_valid(buf)
        or buf_option(buf, "buflisted") ~= true
        or buf_option(buf, "buftype") ~= ""
    then
        return nil
    end

    local name = vim.api.nvim_buf_get_name(buf)
    if name == "" or name:match("^%a[%w+.-]*://") then
        return nil
    end

    local path = normalize(name)
    return is_directory(path) and nil or path
end

---@return { buf: number, path: string }[]
local function real_file_buffers()
    local buffers, seen = {}, {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local path = real_file_path(buf)
        if path and not seen[path] then
            seen[path] = true
            table.insert(buffers, { buf = buf, path = path })
        end
    end
    return buffers
end

---@return { buf: number, path: string }[]
local function modified_real_file_buffers()
    local modified = {}
    for _, item in ipairs(real_file_buffers()) do
        if buf_option(item.buf, "modified") == true then
            table.insert(modified, item)
        end
    end
    return modified
end

---@param win number
---@return table?
local function capture_leaf(win)
    local path = vim.api.nvim_win_is_valid(win)
        and real_file_path(vim.api.nvim_win_get_buf(win))
    if not path then
        return nil
    end

    local cursor = vim.api.nvim_win_get_cursor(win)
    local ok, view = pcall(vim.api.nvim_win_call, win, vim.fn.winsaveview)
    return {
        type = "leaf",
        path = path,
        cursor = { line = cursor[1], col = cursor[2] },
        view = ok and view or nil,
    }
end

---@param node table
---@return table?
local function capture_layout_node(node)
    if node[1] == "leaf" then
        return capture_leaf(node[2])
    end

    local children = {}
    for _, child in ipairs(node[2] or {}) do
        local captured = capture_layout_node(child)
        if captured then
            table.insert(children, captured)
        end
    end

    if #children == 0 then
        return nil
    end
    return #children == 1 and children[1]
        or { type = node[1], children = children }
end

---@param cwd string
local function save_session(cwd)
    local paths = {}
    for _, item in ipairs(real_file_buffers()) do
        table.insert(paths, item.path)
    end

    local ok, encoded = safe(function()
        return vim.json.encode({
            cwd = normalize(cwd),
            buffers = paths,
            current = real_file_path(vim.api.nvim_get_current_buf()),
            layout = capture_layout_node(vim.fn.winlayout()),
        })
    end)
    if not ok then
        vim.notify("Cwd: could not encode session", vim.log.levels.WARN)
        return
    end

    local write_ok, err = safe(function()
        vim.fn.writefile({ encoded }, session_path(cwd))
    end)
    if not write_ok then
        vim.notify(
            "Cwd: could not save session: " .. tostring(err),
            vim.log.levels.WARN
        )
    end
end

---@param cwd string
---@return table?
local function load_session(cwd)
    local path = session_path(cwd)
    if vim.fn.filereadable(path) ~= 1 then
        return nil
    end

    local ok, lines = pcall(vim.fn.readfile, path)
    if not ok then
        return nil
    end

    ok, lines = pcall(vim.json.decode, table.concat(lines, "\n"))
    return ok and type(lines) == "table" and lines or nil
end

---@param buffers { buf: number, path: string }[]
local function close_real_file_buffers(buffers)
    local real_bufs, file_wins = {}, {}
    for _, item in ipairs(buffers) do
        real_bufs[item.buf] = true
    end
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if
            vim.api.nvim_win_is_valid(win)
            and real_bufs[vim.api.nvim_win_get_buf(win)]
        then
            table.insert(file_wins, win)
        end
    end

    for _, item in ipairs(buffers) do
        local ok, err = safe(function()
            if vim.api.nvim_buf_is_valid(item.buf) then
                vim.api.nvim_buf_delete(item.buf, { force = false })
            end
        end)
        if not ok then
            vim.notify(
                "Cwd: could not close "
                    .. vim.fn.fnamemodify(item.path, ":~")
                    .. ": "
                    .. tostring(err),
                vim.log.levels.WARN
            )
        end
    end

    for _, win in ipairs(file_wins) do
        if #vim.api.nvim_tabpage_list_wins(0) <= 1 then
            return
        end
        if
            vim.api.nvim_win_is_valid(win)
            and is_empty_buffer(vim.api.nvim_win_get_buf(win))
        then
            pcall(vim.api.nvim_win_close, win, false)
        end
    end
end

---@param path string
local function load_listed_buffer(path)
    local buf = vim.fn.bufadd(path)
    if buf <= 0 then
        return
    end
    pcall(vim.fn.bufload, buf)
    safe(function()
        vim.api.nvim_set_option_value("buflisted", true, { buf = buf })
    end)
end

---@param buf number
---@return boolean
local function is_cwd_fallback_buffer(buf)
    local ok, value = pcall(vim.api.nvim_buf_get_var, buf, "cwd_fallback")
    return ok and value == true
end

local function close_cwd_fallback_buffers()
    local buffers, seen = {}, {}
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_is_valid(win)
            and vim.api.nvim_win_get_buf(win)
        if buf and is_cwd_fallback_buffer(buf) then
            if not seen[buf] then
                seen[buf] = true
                table.insert(buffers, buf)
            end
            if #vim.api.nvim_tabpage_list_wins(0) > 1 then
                pcall(vim.api.nvim_win_close, win, false)
            else
                vim.api.nvim_set_current_win(win)
                vim.cmd("enew")
            end
        end
    end

    for _, buf in ipairs(buffers) do
        safe(function()
            if vim.api.nvim_buf_is_valid(buf) then
                vim.api.nvim_buf_delete(buf, { force = true })
            end
        end)
    end
end

---@return number
local function ensure_anchor_window()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if
            vim.api.nvim_win_is_valid(win)
            and is_empty_buffer(vim.api.nvim_win_get_buf(win))
        then
            vim.api.nvim_set_current_win(win)
            return win
        end
    end
    vim.cmd("botright new")
    return vim.api.nvim_get_current_win()
end

---@param win number
---@param path string
---@return boolean
local function edit_file_in_window(win, path)
    if not vim.api.nvim_win_is_valid(win) then
        return false
    end

    vim.api.nvim_set_current_win(win)
    local ok, err = safe(function()
        vim.cmd("silent keepalt edit " .. vim.fn.fnameescape(path))
    end)
    if ok then
        return true
    end

    vim.notify(
        "Cwd: could not open "
            .. vim.fn.fnamemodify(path, ":~")
            .. ": "
            .. tostring(err),
        vim.log.levels.WARN
    )
    return false
end

---@param node table
---@param win number
---@param opened table<string, number>
local function restore_layout_node(node, win, opened)
    if node.type == "leaf" then
        if
            type(node.path) ~= "string"
            or not edit_file_in_window(win, node.path)
        then
            return
        end

        opened[node.path] = win
        if type(node.view) == "table" then
            pcall(vim.api.nvim_win_call, win, function()
                vim.fn.winrestview(node.view)
            end)
        elseif type(node.cursor) == "table" and node.cursor.line then
            safe(function()
                vim.api.nvim_win_set_cursor(
                    win,
                    { node.cursor.line, node.cursor.col or 0 }
                )
            end)
        end
        return
    end

    local children = type(node.children) == "table" and node.children or {}
    local wins = { win }
    for i = 2, #children do
        vim.api.nvim_set_current_win(wins[i - 1])
        vim.cmd(
            node.type == "row" and "rightbelow vsplit" or "rightbelow split"
        )
        wins[i] = vim.api.nvim_get_current_win()
    end
    for i, child in ipairs(children) do
        restore_layout_node(child, wins[i], opened)
    end
end

---@param dir string
local function open_oil(dir)
    local win = ensure_anchor_window()
    vim.api.nvim_set_current_win(win)

    local ok, oil = pcall(require, "oil")
    if ok and type(oil.open) == "function" then
        oil.open(dir)
    else
        vim.cmd("edit " .. vim.fn.fnameescape(dir))
    end

    pcall(
        vim.api.nvim_buf_set_var,
        vim.api.nvim_get_current_buf(),
        "cwd_fallback",
        true
    )
end

---@param dir string
local function restore_session(dir)
    local session = load_session(dir)
    local buffers = session and session.buffers
    if type(buffers) ~= "table" or #buffers == 0 then
        open_oil(dir)
        return
    end

    local opened = {}
    assert(session ~= nil)
    if type(session.layout) == "table" then
        restore_layout_node(session.layout, ensure_anchor_window(), opened)
    else
        local first = type(session.current) == "string" and session.current
            or buffers[1]
        if
            type(first) == "string"
            and edit_file_in_window(ensure_anchor_window(), first)
        then
            opened[first] = vim.api.nvim_get_current_win()
        end
    end

    for _, path in ipairs(buffers) do
        if type(path) == "string" and not opened[path] then
            load_listed_buffer(path)
        end
    end

    local current = session.current
    if
        type(current) == "string"
        and opened[current]
        and vim.api.nvim_win_is_valid(opened[current])
    then
        vim.api.nvim_set_current_win(opened[current])
    end
    safe(function()
        vim.cmd("wincmd =")
    end)
end

---@param dir string
local function track_cwd_access(dir)
    local ok, file_picker = pcall(require, "fff.file_picker")
    if ok and type(file_picker.track_access) == "function" then
        pcall(file_picker.track_access, entry_path(dir))
    end
end

---@param path string
---@return boolean
local function change_to(path)
    path = normalize(path)
    local dirty = modified_real_file_buffers()
    if #dirty > 0 then
        local shown = {}
        for i, item in ipairs(dirty) do
            table.insert(
                shown,
                i > 8 and "…" or vim.fn.fnamemodify(item.path, ":~")
            )
            if i > 8 then
                break
            end
        end
        vim.notify(
            "Cwd: unsaved file buffers. Write or discard them before changing cwd:\n"
                .. table.concat(shown, "\n"),
            vim.log.levels.WARN
        )
        return false
    end

    local old_cwd = normalize(vim.fn.getcwd())
    local buffers = real_file_buffers()
    save_session(old_cwd)
    close_real_file_buffers(buffers)
    close_cwd_fallback_buffers()

    vim.cmd("cd " .. vim.fn.fnameescape(path))
    restore_session(path)
    track_cwd_access(path)

    vim.notify("Cwd: " .. vim.fn.fnamemodify(path, ":~"))
    return true
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

    local opened, err = pcall(function()
        picker.open({
            cwd = cwd_dir,
            title = "Change cwd",
            prompt = "Cwd > ",
            renderer = cwd_renderer,
            preview = { enabled = false },
            layout = { height = 0.35, width = 0.55 },
        })
    end)
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
