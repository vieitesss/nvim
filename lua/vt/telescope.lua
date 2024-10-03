local builtin = require("telescope.builtin")

local M = {}

function os.capture(cmd, raw)
    local f = assert(io.popen(cmd, 'r'))
    local s = assert(f:read('*a'))
    f:close()
    if raw then return s end
    s = string.gsub(s, '^%s+', '')
    s = string.gsub(s, '%s+$', '')
    s = string.gsub(s, '[\n\r]+', ' ')
    return s
end

M.search_dotfiles = function()
    local out = os.capture("uname -a", false)
    local pc = string.match(out, "^([%w]+)")

    local dir = ""
    if pc == "Darwin" then
        dir = "~/.mac_config/"
    elseif pc == "Linux" then
        dir = "~/.dot_linux/"
    end

    builtin.find_files({
        prompt_title = "Dotfiles",
        cwd = dir
    })
end

M.search_obsidian = function()
    builtin.find_files({
        prompt_title = "Obsidian",
        cwd = "~/obsidian/"
    })
end

M.grep_obsidian = function()
    builtin.live_grep({
        prompt_title = "Obsidian | Live grep",
        cwd = "~/obsidian/"
    })
end

M.search_nvim = function()
    builtin.find_files({
        prompt_title = "Nvim Config",
        cwd = "~/.config/nvim/",
    })
end

M.search_projects = function()
    builtin.find_files({
        prompt_title = "My projects",
        cwd = "~/projects/",
        follow = true,
        hidden = false,
    })
end

return M
