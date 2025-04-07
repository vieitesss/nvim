return {
    "williamboman/mason.nvim",
    event = { "BufEnter" },
    opts = {
        automatic_installation = true,
        ui = {
            icons = {
                package_installed = "",
                package_pending = "➜",
                package_uninstalled = "",
            },
        },
    },
}
