local M = {}

local function find_elements(elements, tempname)
    local input = vim.fn.tempname()
    vim.fn.writefile(elements, input)

    local script = "fzf --multi < "
        .. vim.fn.shellescape(input)
        .. " > "
        .. vim.fn.shellescape(tempname)
        .. "; fzf_status=$?; "
        .. "case $fzf_status in 0|1|130) exit 0;; "
        .. "*) exit $fzf_status;; esac"
    local cmd = "sh -c " .. vim.fn.shellescape(script)

    local shell_error = 0
    local ok, err = pcall(function()
        vim.cmd("!" .. cmd)
        shell_error = vim.v.shell_error
        vim.cmd("redraw!")
    end)
    if ok and shell_error ~= 0 then
        ok = false
        err = "fzf failed with exit code " .. shell_error
    end

    local result = ok and vim.fn.readfile(tempname) or nil
    vim.fn.delete(input)
    vim.fn.delete(tempname)

    if not ok then
        error(err)
    end

    return result
end

---@param elements string[]?
---@return string[]?
M.fzf = function(elements)
    if vim.fn.executable("fzf") ~= 1 then
        error("fzf executable not found")
    end

    local tempname = vim.fn.tempname()

    if elements ~= nil then
        return find_elements(elements, tempname)
    end

    local awk = vim.fn.shellescape('{ print $1":1:0" }')
    local outfile = vim.fn.shellescape(tempname)

    local cmd = "fzf --multi | awk " .. awk .. " > " .. outfile

    local ok, err = pcall(function()
        vim.cmd("!" .. cmd)
        vim.cmd("cfile " .. vim.fn.fnameescape(tempname))
        vim.cmd("redraw!")
    end)

    vim.fn.delete(tempname)

    if not ok then
        error(err)
    end
end

vim.api.nvim_create_user_command("Files", function()
    M.fzf()
end, {
    nargs = "*",
})

return M
