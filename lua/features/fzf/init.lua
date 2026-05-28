local M = {}

local show_terminal_cursor

local function find_elements(elements, callback)
    local input = vim.fn.tempname()
    local output = vim.fn.tempname()
    vim.fn.writefile(elements, input)

    local script = "fzf --multi < "
        .. vim.fn.shellescape(input)
        .. " > "
        .. vim.fn.shellescape(output)
        .. "; fzf_status=$?; "
        .. "case $fzf_status in 0|1|130) exit 0;; "
        .. "*) exit $fzf_status;; esac"

    vim.cmd("botright 15new")
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].bufhidden = "wipe"

    local job = vim.fn.jobstart({ vim.o.shell, vim.o.shellcmdflag, script }, {
        term = true,
        on_exit = function(_, code)
            vim.schedule(function()
                if vim.api.nvim_win_is_valid(win) then
                    vim.api.nvim_win_close(win, true)
                end

                show_terminal_cursor()

                local result = nil
                local err = nil
                if code == 0 then
                    result = vim.fn.readfile(output)
                else
                    err = "fzf failed with exit code " .. code
                end

                vim.fn.delete(input)
                vim.fn.delete(output)
                vim.cmd("redraw!")
                callback(result, err)
            end)
        end,
    })

    if job <= 0 then
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
        vim.fn.delete(input)
        vim.fn.delete(output)
        error("failed to start fzf")
    end

    vim.cmd("startinsert")
end

local function default_files_command()
    if vim.fn.executable("fd") == 1 then
        return "fd --type f --hidden --follow --exclude .git"
    end

    return "find . -type f -not -path '*/.git/*' | sed 's#^\\./##'"
end

show_terminal_cursor = function()
    pcall(vim.api.nvim_chan_send, vim.v.stderr, "\027[?25h")
end

local function open_files(source_cmd)
    local tempname = vim.fn.tempname()
    local outfile = vim.fn.shellescape(tempname)
    local header = vim.fn.shellescape("$ " .. source_cmd)
    local cmd = source_cmd
        .. " | fzf --multi --header "
        .. header
        .. " > "
        .. outfile

    vim.cmd("botright 15new")
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].bufhidden = "wipe"

    local job = vim.fn.jobstart({ vim.o.shell, vim.o.shellcmdflag, cmd }, {
        term = true,
        on_exit = function(_, code)
            vim.schedule(function()
                if vim.api.nvim_win_is_valid(win) then
                    vim.api.nvim_win_close(win, true)
                end

                show_terminal_cursor()

                if code == 0 and vim.fn.getfsize(tempname) > 0 then
                    for _, file in ipairs(vim.fn.readfile(tempname)) do
                        vim.cmd("edit " .. vim.fn.fnameescape(file))
                    end
                end

                vim.fn.delete(tempname)
                vim.cmd("redraw!")
            end)
        end,
    })

    if job <= 0 then
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
        vim.fn.delete(tempname)
        error("failed to start fzf")
    end

    vim.cmd("startinsert")
end

---@param elements string[]?
---@param callback fun(result: string[]?, err: string?)?
M.fzf = function(elements, callback)
    if vim.fn.executable("fzf") ~= 1 then
        error("fzf executable not found")
    end

    if elements ~= nil then
        if callback == nil then
            error("fzf element picker requires a callback")
        end
        return find_elements(elements, callback)
    end

    open_files(default_files_command())
end

M.setup = function()
    vim.api.nvim_create_user_command("Files", function(opts)
        open_files(opts.args ~= "" and opts.args or default_files_command())
    end, {
        nargs = "*",
        complete = "shellcmd",
    })
end

return M
