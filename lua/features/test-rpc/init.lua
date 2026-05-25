local M = {}

local binary = vim.fn.stdpath("config") .. "/bin/test-rpc"

local channel

---@return number?
local function rpc()
    if not channel then
        channel = vim.fn.jobstart(binary, { rpc = true })
    end

    if channel < 1 then
        vim.log.error("an error ocurred starting the test-rpc job")
        return nil
    end

    return channel
end

M.run = function()
    local c = rpc()
    if not c then return end

    local result = vim.rpcrequest(c, "multiply", { "2", "a" })
    vim.print("Result: " ..  result)
end

return M
