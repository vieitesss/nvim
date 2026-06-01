local M = {}

local ag = vim.api.nvim_create_augroup("NeovimFeatures", { clear = true })

local function ensure_autocmd()
    vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
        pattern = { "*" },
        group = ag,
        once = true,
        callback = function(_)
            local job = require("features.rpc")._job
            if job and job > 0 then
                vim.fn.jobstop(job)
            end
        end,
    })
end

M.cwd = function()
    ensure_autocmd()
    return require("features.cwd")
end

return M
