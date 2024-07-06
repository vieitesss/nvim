vim.opt.conceallevel = 1

-- create a new note from current buffer
vim.keymap.set("n", "<Leader>on", "<cmd>ObsidianTemplate note<cr>", { silent = true })
-- find files inside obsidian vault
vim.keymap.set("n", "<Leader>os", "<cmd>lua require('vt.telescope').search_obsidian()<cr>", { silent = true })
-- find the current file backlinks
vim.keymap.set("n", "<Leader>ob", "<cmd>ObsidianBacklink <cr>", { silent = true })
-- live grep inside obsidian vault
vim.keymap.set("n", "<Leader>og", "<cmd>lua require('vt.telescope').grep_obsidian()<cr>", { silent = true })
-- live grep inside obsidian vault
vim.keymap.set("n", "<Leader>oc", "<cmd>ObsidianNew<cr>", { silent = true })

return {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    event = {
        "BufReadPre " .. vim.fn.expand "~" .. "/obsidian/**.md",
        "BufNewFile " .. vim.fn.expand "~" .. "/obsidian/**.md",
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    opts = {
        disable_frontmatter = true,
        workspaces = {
            {
                name = "personal",
                path = "~/obsidian",
            }
        },
        completion = {
            nvim_cmp = true,
            min_chars = 2
        },
        notes_subdir = "inbox",
        new_notes_location = "notes_subdir",
        -- note_id_func = function(title)
        --     -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
        --     -- In this case a note with the title 'My new note' will be given an ID that looks
        --     -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
        --     local suffix = ""
        --     if title ~= nil then
        --         -- If title is given, transform it into valid file name.
        --         suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        --     else
        --         -- If title is nil, just add 4 random uppercase letters to the suffix.
        --         for _ = 1, 4 do
        --             suffix = suffix .. string.char(math.random(65, 90))
        --         end
        --     end
        --     return tostring(os.time()) .. "-" .. suffix
        -- end,
        templates = {
            folder = "Templates",
            date_format = "%Y-%m-%d",
            time_format = "%H:%M",
            -- A map for custom variables, the key should be the variable and the value a function
            substitutions = {},
        },
        follow_url_func = function(url)
            -- Open the URL in the default web browser.
            vim.fn.jobstart({ "open", url }) -- Mac OS
        end,
        open_app_foreground = false,
        picker = {
            name = "telescope.nvim",
            mappings = {
                -- Create a new note from your query.
                new = "<C-x>",
                -- Insert a link to the selected note.
                insert_link = "<C-l>",
            },
        },
        ui = {
            enable = true,          -- set to false to disable all additional syntax features
            update_debounce = 200,  -- update delay after a text change (in milliseconds)
            max_file_length = 5000, -- disable UI features for files with more than this many lines
            -- Define how various check-boxes are displayed
            checkboxes = {
                -- NOTE: the 'char' value has to be a single character, and the highlight groups are defined below.
                [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
                ["x"] = { char = "", hl_group = "ObsidianDone" },
                [">"] = { char = "", hl_group = "ObsidianRightArrow" },
                ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
                ["!"] = { char = "", hl_group = "ObsidianImportant" },
                -- Replace the above with this if you don't have a patched font:
                -- [" "] = { char = "☐", hl_group = "ObsidianTodo" },
                -- ["x"] = { char = "✔", hl_group = "ObsidianDone" },

                -- You can also add more custom ones...
            },
            -- Use bullet marks for non-checkbox lists.
            bullets = { char = "•", hl_group = "ObsidianBullet" },
            external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
            -- Replace the above with this if you don't have a patched font:
            -- external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
            reference_text = { hl_group = "ObsidianRefText" },
            highlight_text = { hl_group = "ObsidianHighlightText" },
            tags = { hl_group = "ObsidianTag" },
            block_ids = { hl_group = "ObsidianBlockID" },
            hl_groups = {
                -- The options are passed directly to `vim.api.nvim_set_hl()`. See `:help nvim_set_hl`.
                ObsidianTodo = { bold = true, fg = "#f78c6c" },
                ObsidianDone = { bold = true, fg = "#89ddff" },
                ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
                ObsidianTilde = { bold = true, fg = "#ff5370" },
                ObsidianImportant = { bold = true, fg = "#d73128" },
                ObsidianBullet = { bold = true, fg = "#89ddff" },
                ObsidianRefText = { underline = true, fg = "#c792ea" },
                ObsidianExtLinkIcon = { fg = "#c792ea" },
                ObsidianTag = { italic = true, fg = "#89ddff" },
                ObsidianBlockID = { italic = true, fg = "#89ddff" },
                ObsidianHighlightText = { bg = "#75662e" },
            },
        },
        -- Specify how to handle attachments.
        attachments = {
            -- The default folder to place images in via `:ObsidianPasteImg`.
            -- If this is a relative path it will be interpreted as relative to the vault root.
            -- You can always override this per image by passing a full path to the command instead of just a filename.
            img_folder = "Images",
            -- A function that determines the text to insert in the note when pasting an image.
            -- It takes two arguments, the `obsidian.Client` and an `obsidian.Path` to the image file.
            -- This is the default implementation.
            ---@param client obsidian.Client
            ---@param path obsidian.Path the absolute path to the image file
            ---@return string
            img_text_func = function(client, path)
                path = client:vault_relative_path(path) or path
                return string.format("![%s](%s)", path.name, path)
            end,
        },
    }
}
