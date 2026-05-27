local core = require("features.cwd.core")
local session = require("features.cwd.session")

local M = {}

---@class CwdSetupOptions
---@field paths string[]? Directories whose first-level children can be selected.
---@field include_home_git_repos boolean? Include Git repositories directly under $HOME.

---@type CwdConfig
local config = {
    paths = {},
    include_home_git_repos = true,
}

---@return string[]
local function list()
    local dirs = {}
    require("features.rpc").rpc("List", config, function(result, err)
        if err then
            vim.print(err)
            return
        end

        dirs = result
    end)

    return dirs
end

---@param target_path string
---@return boolean
local function change_to(target_path)
    target_path = core.normalize(target_path)

    local dirty = session.modified_real_file_buffers()
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

    local old_cwd = core.normalize(vim.fn.getcwd())
    local buffers = session.real_file_buffers()
    session.save(old_cwd)
    session.close_real_file_buffers(buffers)
    session.close_cwd_fallback_buffers()

    vim.cmd("cd " .. vim.fn.fnameescape(target_path))
    session.restore(target_path)
    core.track_access(target_path)

    vim.notify("Cwd: " .. vim.fn.fnamemodify(target_path, ":~"))
    return true
end

---@return nil
function M.pick()
    local dirs = list()
    if #dirs == 0 then
        vim.notify("No cwd directories found")
        return
    end
    core.refresh_index(dirs)

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
        return core.item_to_dir(item)
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
            cwd = core.index_dir,
            title = "Change cwd",
            prompt = "Cwd > ",
            renderer = core,
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
