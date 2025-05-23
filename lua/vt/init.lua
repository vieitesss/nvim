RELOAD = function(...)
    return require("plenary.reload").reload_module(...)
end

R = function(name)
    RELOAD(name)
    return require(name)
end

OPENPDFVIEWER = function()
    local path_no_ext = vim.fn.expand("%:p:r")
    -- os.execute("open " .. path_no_ext .. ".pdf -a Skim")
    os.execute("mupdf-gl " .. path_no_ext .. ".pdf 2>/dev/null &")
end

local M = {}

M.dotfiles_dir = function()
    local out = vim.fn.system("uname -a")
    local pc = string.match(out, "^([%w]+)")

    local dir = ""
    if pc == "Darwin" then
        dir = "~/.mac_config/"
    elseif pc == "Linux" then
        dir = "~/.dot_linux/"
    end

    return dir
end

return M
