local builtin = require("telescope.builtin")

local M = {}

M.search_dotfiles = function()
    builtin.find_files({
        prompt_title = "Dotfiles",
        -- cwd = "~/.dotfiles/",
        -- cwd = "~/.mac_config/",
        cwd = "~/.dot_linux/"
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
