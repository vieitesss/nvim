local M = {}

local sessions_dir = vim.fn.stdpath("data") .. "/sessions/"
vim.fn.mkdir(sessions_dir, "p")

local config = {
    -- Save normal/listed buffers. Terminal process state is intentionally not
    -- saved; use tmux/zellij if terminal persistence is needed.
    sessionoptions = "buffers,curdir,tabpages,winsize",
}

-- URL-style encoding so any absolute path is a valid filename:
--   % -> %25   (must come first)
--   / -> %2F
local function encode(path)
    return path:gsub("%%", "%%25"):gsub("/", "%%2F")
end

local function decode(name)
    -- order matters: decode %2F first, then %25
    local decoded = name:gsub("%%2F", "/"):gsub("%%25", "%%")
    return decoded
end

local function session_path(name)
    return sessions_dir .. encode(name) .. ".vim"
end

local function cwd_name()
    return vim.fn.getcwd()
end

local function normalize_sessionoptions(options)
    if type(options) == "table" then
        return table.concat(options, ",")
    end
    return options or config.sessionoptions
end

local function save(name, opts)
    opts = opts or {}
    name = name or cwd_name()

    local old = vim.o.sessionoptions
    vim.o.sessionoptions = normalize_sessionoptions(config.sessionoptions)
    vim.cmd("mksession! " .. vim.fn.fnameescape(session_path(name)))
    vim.o.sessionoptions = old

    if not opts.silent then
        vim.notify("Session saved: " .. vim.fn.fnamemodify(name, ":~"))
    end
end

local function refresh_highlighting()
    -- Sessions are sourced from VimEnter/autoload after the normal BufRead
    -- startup path, so restored buffers can miss syntax setup. Re-detect the
    -- filetype and ensure the buffer-local 'syntax' option is populated.
    vim.cmd("silent! syntax enable")

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if
            vim.api.nvim_buf_is_loaded(buf)
            and vim.bo[buf].buflisted
            and vim.bo[buf].buftype == ""
        then
            vim.api.nvim_buf_call(buf, function()
                vim.cmd("silent! filetype detect")
                if vim.bo.filetype ~= "" and vim.bo.syntax == "" then
                    vim.bo.syntax = vim.bo.filetype
                end
            end)
        end
    end
end

local function load(name, opts)
    opts = opts or {}
    local path = session_path(name)
    if vim.fn.filereadable(path) == 0 then
        return false
    end
    -- Wipe buffers before restoring so we start clean.
    vim.cmd("silent! %bdelete!")
    local ok, err = pcall(function()
        vim.cmd("source " .. vim.fn.fnameescape(path))
    end)
    if ok then
        vim.schedule(refresh_highlighting)
    elseif not opts.silent then
        vim.notify("Session load error: " .. tostring(err), vim.log.levels.WARN)
    end
    return ok
end

local function list()
    local files = vim.fn.glob(sessions_dir .. "*.vim", false, true)
    local names = {}
    for _, f in ipairs(files) do
        -- filename without extension
        table.insert(names, decode(vim.fn.fnamemodify(f, ":t:r")))
    end
    table.sort(names)

    return names
end

local function remove(name)
    local ok = vim.fn.delete(session_path(name)) == 0
    if ok then
        vim.notify("Session deleted: " .. vim.fn.fnamemodify(name, ":~"))
    else
        vim.notify(
            "Could not delete session: " .. vim.fn.fnamemodify(name, ":~"),
            vim.log.levels.WARN
        )
    end
    return ok
end

local session_renderer = {}

local function relative_path_to_session_name(path)
    if not path or path == "" then
        return nil
    end
    return decode(vim.fn.fnamemodify(path, ":t:r"))
end

local function item_to_session_name(item)
    if not item then
        return nil
    end
    return relative_path_to_session_name(item.relative_path or item.name)
end

function session_renderer.render_line(item)
    local name = item_to_session_name(item)
    return { name and vim.fn.fnamemodify(name, ":~") or "" }
end

function session_renderer.apply_highlights(
    item,
    ctx,
    item_idx,
    buf,
    ns_id,
    line_idx,
    line_content
)
    local selected = ctx.selected_files
        and ctx.selected_files[item.relative_path]
    local line_hl = item_idx == ctx.cursor and "Visual"
        or (selected and (ctx.config.hl.selected or "FFFSelected"))

    if line_hl then
        vim.api.nvim_buf_set_extmark(buf, ns_id, line_idx - 1, 0, {
            end_col = #line_content,
            hl_group = line_hl,
        })
    end

    if selected then
        vim.api.nvim_buf_set_extmark(buf, ns_id, line_idx - 1, 0, {
            sign_text = "▊",
            sign_hl_group = item_idx == ctx.cursor
                    and (ctx.config.hl.selected_active or "FFFSelectedActive")
                or (ctx.config.hl.selected or "FFFSelected"),
            priority = 1001,
        })
    end
end

local function pick_session(title, on_choice)
    if #list() == 0 then
        vim.notify("No sessions saved yet")
        return
    end

    local ok, picker = pcall(require, "fff.picker_ui")
    if not ok then
        vim.notify("Could not load fff session picker", vim.log.levels.WARN)
        return
    end
    if picker.state.active then
        return
    end

    local original_select = picker.select
    local original_close = picker.close
    local restored = false

    local function restore()
        if restored then
            return
        end
        restored = true
        picker.select = original_select
        picker.close = original_close
    end

    local function selected_session()
        local item = picker.state.filtered_items[picker.state.cursor]
        return item_to_session_name(item)
    end

    picker.close = function(...)
        restore()
        return original_close(...)
    end

    picker.select = function()
        local choice = selected_session()
        if not choice then
            return
        end
        restore()
        original_close()
        on_choice(choice)
    end

    local opened, err = pcall(picker.open, {
        cwd = sessions_dir,
        title = title,
        prompt = "Sessions > ",
        renderer = session_renderer,
        preview = { enabled = false },
        layout = { height = 0.35, width = 0.55 },
    })
    if not opened or not picker.state.active then
        restore()
        vim.notify(
            "Could not open fff session picker: " .. tostring(err),
            vim.log.levels.WARN
        )
        return
    end

    local function selected_sessions()
        local choices = {}
        for relative_path in pairs(picker.state.selected_files or {}) do
            local name = relative_path_to_session_name(relative_path)
            if name then
                table.insert(choices, name)
            end
        end
        table.sort(choices)

        if #choices == 0 then
            local choice = selected_session()
            if choice then
                table.insert(choices, choice)
            end
        end

        return choices
    end

    local function delete_selected()
        local choices = selected_sessions()
        if #choices == 0 then
            return
        end

        local deleted = {}
        local deleted_count = 0
        for _, choice in ipairs(choices) do
            if remove(choice) then
                deleted[choice] = true
                deleted_count = deleted_count + 1
            end
        end
        if deleted_count == 0 then
            return
        end

        picker.state.selected_files = {}
        picker.state.selected_items = {}

        local function filter_deleted(items)
            local filtered = {}
            for _, item in ipairs(items or {}) do
                local name = item_to_session_name(item)
                if not name or not deleted[name] then
                    table.insert(filtered, item)
                end
            end
            return filtered
        end

        picker.state.items = filter_deleted(picker.state.items)
        picker.state.filtered_items =
            filter_deleted(picker.state.filtered_items)
        picker.state.cursor =
            math.min(picker.state.cursor, #picker.state.filtered_items)
        if picker.state.cursor < 1 then
            picker.state.cursor = 1
        end
        if picker.state.pagination then
            picker.state.pagination.total_matched = math.max(
                0,
                (picker.state.pagination.total_matched or 0) - deleted_count
            )
        end
        picker.state.last_status_info = nil

        -- Keep fff's backing index in sync for subsequent searches without
        -- depending on its async scanner before updating the visible list.
        pcall(picker.change_indexing_directory, sessions_dir)

        picker.render_list()
        picker.update_preview()
        picker.update_status()
    end

    if picker.state.input_buf then
        vim.keymap.set({ "i", "n" }, "<C-d>", delete_selected, {
            buffer = picker.state.input_buf,
            desc = "Session: delete",
            silent = true,
        })
    end
    if picker.state.list_buf then
        vim.keymap.set("n", "<C-d>", delete_selected, {
            buffer = picker.state.list_buf,
            desc = "Session: delete",
            silent = true,
        })
    end
end

function M.setup(opts)
    opts = opts or {}
    if opts.sessionoptions ~= nil then
        config.sessionoptions = opts.sessionoptions
    end

    -- Auto-save when leaving Neovim.
    vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
            save(cwd_name(), { silent = true })
        end,
    })

    -- Auto-load the session for the cwd when Neovim starts with no file args.
    vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
            if vim.fn.argc() == 0 then
                load(cwd_name(), { silent = true })
            end
        end,
    })

    local map = vim.keymap.set

    map("n", "<leader>ss", function()
        save(cwd_name())
    end, { desc = "Session: save", silent = true })

    map("n", "<leader>sl", function()
        pick_session("Load session", function(choice)
            save(cwd_name(), { silent = true })
            load(choice)
        end)
    end, { desc = "Session: load", silent = true })

    map("n", "<leader>sr", function()
        pick_session("Remove session", remove)
    end, { desc = "Session: remove", silent = true })
end

return M
