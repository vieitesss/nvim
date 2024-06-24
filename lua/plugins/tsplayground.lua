return {
    "nvim-treesitter/playground",
    event = "BufReadPre",
    dependencies = {
        "nvim-treesitter/nvim-treesitter"
    },
    build = ":TSInstall query"
}
