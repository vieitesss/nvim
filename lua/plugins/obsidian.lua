vim.opt.conceallevel = 1

return {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    event = {
        "BufReadPre " .. vim.fn.expand "~" .. "/personal/obsidian/**.md",
        "BufNewFile " .. vim.fn.expand "~" .. "/personal/obsidian/**.md",
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    keys = {
        { "<Leader>ob", "<cmd>ObsidianBacklinks<cr>" },
        { "<Leader>on", "<cmd>ObsidianNew<cr>" },
        { "<Leader>os", "<cmd>ObsidianQuickSwitch<cr>" },
    },
    opts = {
        disable_frontmatter = true,
        workspaces = {
            {
                name = "personal",
                path = "~/personal/obsidian",
            }
        },
        -- completion = {
        --     nvim_cmp = true,
        --     min_chars = 2
        -- },
        notes_subdir = "inbox",
        new_notes_location = "notes_subdir",
        -- note_id_func = function(title)
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
        --     return tostring(suffix)
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
            name = "fzf-lua",
            mappings = {
                -- Create a new note from your query.
                new = "<C-x>",
                -- Insert a link to the selected note.
                insert_link = "<C-l>",
            },
        },
    }
}
