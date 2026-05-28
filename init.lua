require("plugins")
require("features.packui").setup()
require("configs")
require("lsp")
require("keymaps")
require("features.statusline")
require("autocmds")
-- require("features.umbraline")
require("features.cwd").setup({
    paths = {
        "~/personal",
        "~/prefapp",
        "~/pre-vieitesss",
        "~/firestartr-pre",
        "~/firestartr-pro",
        "~/firestartr-demo",
        "~/.config",
    },
    include_home_git_repos = true
})
require("features.term").setup()
