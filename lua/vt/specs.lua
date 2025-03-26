LAZY_PLUGIN_SPEC = {}

local function spec(item)
  table.insert(LAZY_PLUGIN_SPEC, { import = item })
end

-- spec("plugins.bracey")
-- spec("plugins.carbon")
spec("plugins.cmp")
spec("vt.command")
-- spec("plugins.comp-mode")
-- spec("plugins.colorschemes.accent")
spec("plugins.colorschemes.noirbuddy")
-- spec("plugins.colorschemes.everforest")
-- spec("plugins.colorschemes.ashen")
-- spec("plugins.colorschemes.basic")
-- spec("plugins.colorschemes.catppuccin")
-- spec("plugins.colorschemes.gruvbox")
-- spec("plugins.colorschemes.kanagawa")
-- spec("plugins.colorschemes.mellifluous")
-- spec("plugins.colorschemes.monokai-pro")
-- spec("plugins.colorschemes.nightfox")
-- spec("plugins.colorschemes.nord")
-- spec("plugins.colorschemes.rose-pine")
-- spec("plugins.colorschemes.tokyonight")
-- spec("plugins.colorschemes.vague")
-- spec("plugins.copilot")
-- spec("plugins.fidget")
spec("plugins.formatter")
-- spec("plugins.fzf-lua")
-- spec("plugins.gitsigns")
spec("plugins.harpoon")
spec("plugins.lsp")
spec("plugins.lualine")
-- spec("plugins.luasnip")
spec("plugins.markdown")
-- spec("plugins.mini.icons")
spec("plugins.mini.pick")
-- spec("plugins.obsidian")
spec("plugins.oil")
-- spec("plugins.quickfix")
-- spec("plugins.rename")
-- spec("plugins.spring-java")
-- spec("plugins.telescope")
spec("plugins.tmux")
spec("plugins.treesitter")
-- spec("plugins.trouble")
-- spec("plugins.tsautotag")
-- spec("plugins.tsplayground")
spec("plugins.vim-fugitive")
-- spec("plugins.vimtex")
