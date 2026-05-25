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
        "~/.config",
    },
})
require("features.term").setup()
require("features.test-rpc").run()
