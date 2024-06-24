return {
    "lervag/vimtex",
    ft = { "tex" },
    lazy = false,
    init = function()
        vim.g.vimtex_view_method = "skim"
        vim.g.latex_view_general_viewer = "skim"
        vim.g.vimtex_compiler_method = "latexmk"
    end
}
