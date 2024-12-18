LAZY_PLUGIN_SPEC = {}

local function spec(item)
  table.insert(LAZY_PLUGIN_SPEC, { import = item })
end

spec("plugins.cmp")
-- spec("plugins.comments")
-- spec("plugins.copilot")
-- spec("plugins.fidget")
spec("plugins.formatter")
spec("plugins.gitsigns")
spec("plugins.harpoon")
spec("plugins.icons")
spec("plugins.spring-java")
spec("plugins.lsp")
spec("plugins.lualine")
spec("plugins.luasnip")
-- spec("plugins.maximizer")
spec("plugins.markdown")
-- spec("plugins.emmet")
-- spec("plugins.bracey")
spec("plugins.vimtex")
-- spec("plugins.nvimtree")
spec("plugins.oil")
spec("plugins.rename")
-- spec("plugins.surround")
spec("plugins.carbon")
spec("plugins.telescope")
spec("plugins.tmux")
spec("plugins.treesitter")
-- spec("plugins.obsidian")
-- spec("plugins.trouble")
-- spec("plugins.tsautotag")
-- spec("plugins.tsplayground")
-- spec("plugins.vim-fugitive")
-- spec("plugins.colorschemes.basic")
-- spec("plugins.colorschemes.catppuccin")
-- spec("plugins.colorschemes.nightfox")
spec("plugins.colorschemes.vague")
-- spec("plugins.colorschemes.nord")
-- spec("plugins.colorschemes.accent")
-- spec("plugins.colorschemes.gruvbox")
-- spec("plugins.colorschemes.rose-pine")
-- spec("plugins.colorschemes.kanagawa")
-- spec("plugins.colorschemes.mellifluous")
-- spec("plugins.colorschemes.monokai-pro")
-- spec("plugins.colorschemes.tokyonight")
