function Transparent()
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "LineNr", { bg = "none", fg = "#666666" })
    vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "none", fg = "#cccccc" })
    vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
    vim.api.nvim_set_hl(0, "GitSignsChange", { bg = "none" })
    vim.api.nvim_set_hl(0, "GitSignsDelete", { bg = "none" })
    vim.api.nvim_set_hl(0, "GitSignsAdd", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

-- Transparent()
