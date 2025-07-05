vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

return {
    cmd = { "Mason", "MasonInstall" },
    "mason-org/mason.nvim",
    opts = {}
}
