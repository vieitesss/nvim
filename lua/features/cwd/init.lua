local core = require("features.cwd.core")
local session = require("features.cwd.session")

local M = {}

---@class CwdConfig
---@field paths string[] Directories whose first-level children can be selected.
---@field include_home_git_repos boolean Include Git repositories directly under $HOME.

---@type CwdConfig
local config = {
    paths = {},
    include_home_git_repos = true,
}

---@param cb fun(result: any)
---@return string[]
M.list = function(cb)
    local dirs = {}
    require("features.rpc").rpc("List", config, function(result, err)
        if err then
            vim.notify(err, vim.log.levels.WARN)
            return
        end

        cb(result)
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

    vim.notify("Cwd: " .. vim.fn.fnamemodify(target_path, ":~"))
    return true
end

---@param dirs string[]
---@param cb fun(dir: string?)
local function pick_dir(dirs, cb)
    local ok, err = pcall(function()
        require("features.fzf").fzf(dirs, function(selected, fzf_err)
            if fzf_err then
                vim.notify(
                    "Could not open fzf cwd picker: " .. tostring(fzf_err),
                    vim.log.levels.WARN
                )
                cb(nil)
                return
            end

            cb(selected and selected[1] or nil)
        end)
    end)
    if not ok then
        vim.notify(
            "Could not open fzf cwd picker: " .. tostring(err),
            vim.log.levels.WARN
        )
        cb(nil)
    end
end

---@return nil
function M.pick()
    M.list(function(result)
        local dirs = result
        if #dirs == 0 then
            vim.notify("No cwd directories found")
            return
        end

        pick_dir(dirs, function(dir)
            if dir then
                change_to(dir)
            end
        end)
    end)
end

---@param opts CwdConfig?
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

M.change_to = change_to

return M
