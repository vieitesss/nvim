P = function(v)
    print(vim.inspect(v))
    return v
end

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

