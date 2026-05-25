local M = {}

local binary = vim.fn.stdpath("config") .. "/bin/test-rpc"

local channel

local function rpc()
    if not channel then
        channel = vim.fn.jobstart(binary, { rpc = true })
    end

    return channel
end

M.run = function()
    local result = vim.rpcrequest(rpc(), "multiply", { "2", "3" })
    vim.print("Result: " ..  result)
end

return M
