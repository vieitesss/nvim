return {
    "JavaHello/spring-boot.nvim",
    name = "spring_boot",
    ft = "java",
    dependencies = {
        "neovim/nvim-lspconfig"
    },
    config = function()
        -- vim.g.spring_boot = {
        --     jdt_extensions_path = nil, -- 默认使用 ~/.vscode/extensions/vmware.vscode-spring-boot-x.xx.x
        --     jdt_extensions_jars = {
        --         "io.projectreactor.reactor-core.jar",
        --         "org.reactivestreams.reactive-streams.jar",
        --         "jdt-ls-commons.jar",
        --         "jdt-ls-extension.jar",
        --     },
        -- }
        require("spring_boot").setup({
            -- ls_path = nil, -- 默认使用 ~/.vscode/extensions/vmware.vscode-spring-boot-x.xx.x
            -- jdtls_name = "jdtls",
            -- log_file = nil,
            -- java_cmd = nil,
        })
        require("spring_boot").init_lsp_commands()
    end
}
