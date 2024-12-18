return {
    "L3MON4D3/LuaSnip",
    lazy = true,
    config = function ()
        require("luasnip.loaders.from_vscode").lazy_load()
    end,
}
