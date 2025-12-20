-- colors/umbraline.lua
-- Umbraline: 3 main code accents (Yellow = funcs/types/consts,
-- Green = strings, Red = errors). Inspired by the "lack" aesthetic.
--
-- Options (set BEFORE :colorscheme):
--   vim.g.umbraline_transparent = false
--   vim.g.umbraline_dim_inactive = true
--   vim.g.umbraline_italic_comments = true
--   vim.g.umbraline_italic_keywords = true
--   vim.g.umbraline_bold = true
--   vim.g.umbraline_high_contrast = false

local M = {}

-- utils
local function hex_to_rgb(hex)
    hex = hex:gsub("#", "")
    return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

local function rgb_to_hex(r, g, b)
    r = math.min(255, math.max(0, math.floor(r + 0.5)))
    g = math.min(255, math.max(0, math.floor(g + 0.5)))
    b = math.min(255, math.max(0, math.floor(b + 0.5)))
    return string.format("#%02x%02x%02x", r, g, b)
end

local function blend(fg, bg, a)
    local r1, g1, b1 = hex_to_rgb(fg)
    local r2, g2, b2 = hex_to_rgb(bg)
    return rgb_to_hex((1 - a) * r2 + a * r1,
        (1 - a) * g2 + a * g1, (1 - a) * b2 + a * b1)
end

local function set_hl(g, s) vim.api.nvim_set_hl(0, g, s) end
local function link(f, t) vim.api.nvim_set_hl(0, f, { link = t, default = false }) end

-- options
local o = {
    transparent     = vim.g.umbraline_transparent or false,
    dim_inactive    = vim.g.umbraline_dim_inactive ~= false,
    italic_comments = vim.g.umbraline_italic_comments ~= false,
    italic_keywords = vim.g.umbraline_italic_keywords ~= false,
    bold            = vim.g.umbraline_bold ~= false,
    high_contrast   = vim.g.umbraline_high_contrast or false,
}
local function maybe(bg) return o.transparent and "NONE" or bg end

-- palette (gruvbox-ish high contrast + 3 accents)
local black                             = "#000000"
local gray1, gray2, gray3, gray4, gray5 = "#141617", "#1d2021", "#282828", "#3c3836", "#504945"
local gray6, gray7, gray8, gray9        = "#7c6f64", "#928374", "#a89984", "#d5c4a1"
local luster                            = "#fbf1c7"

local bg0, bg1, bg2, bg3, bg_dim        = gray2, gray3, gray4, gray5, gray1
local fg0, fg1, fg2, fg3                = "#fbf1c7", "#ebdbb2", "#a89984", "#928374"
local lack                              = "#83a598" -- cool neutral “hint”

local yellow, green, red                = "#fabd2f", "#b8bb26", "#fb4934"

-- derived
local sel                               = blend(lack, bg0, 0.18)
local cursorln                          = blend(lack, bg0, 0.07)
local pmenu                             = bg2
local pmenu_sel                         = blend(lack, bg2, 0.22)
local border                            = blend(lack, bg2, 0.45)
local floatbg                           = bg2
if o.high_contrast then border = blend(lack, bg2, 0.65) end

-- apply
local function apply()
    vim.o.termguicolors = true
    vim.g.colors_name = "umbraline"
    vim.cmd("hi clear")
    if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
    vim.o.background        = "dark"

    -- terminal ANSI (fold non-triad hues into lack/neutral)
    vim.g.terminal_color_0  = bg3
    vim.g.terminal_color_8  = fg3
    vim.g.terminal_color_1  = red
    vim.g.terminal_color_9  = "#d98a93"
    vim.g.terminal_color_2  = green
    vim.g.terminal_color_10 = "#c7d5c0"
    vim.g.terminal_color_3  = yellow
    vim.g.terminal_color_11 = "#dbd3bd"
    vim.g.terminal_color_4  = lack
    vim.g.terminal_color_12 = "#c0cad4"
    vim.g.terminal_color_5  = lack
    vim.g.terminal_color_13 = "#c0cad4"
    vim.g.terminal_color_6  = lack
    vim.g.terminal_color_14 = "#c0cad4"
    vim.g.terminal_color_7  = fg0
    vim.g.terminal_color_15 = luster

    -- Core UI
    set_hl("Normal", { fg = fg0, bg = maybe(bg0) })
    set_hl("NormalNC", { fg = o.dim_inactive and fg2 or fg0, bg = maybe(o.dim_inactive and bg_dim or bg0) })
    set_hl("NormalFloat", { fg = fg0, bg = maybe(floatbg) })
    set_hl("FloatBorder", { fg = border, bg = maybe(floatbg) })
    set_hl("FloatTitle", { fg = lack, bg = maybe(floatbg), bold = o.bold })
    set_hl("WinSeparator", { fg = border, bg = maybe(bg0) })
    set_hl("EndOfBuffer", { fg = maybe(bg0), bg = maybe(bg0) })

    set_hl("LineNr", { fg = fg3, bg = "NONE" })
    set_hl("CursorLineNr", { fg = yellow, bg = "NONE", bold = o.bold })
    set_hl("SignColumn", { fg = fg2, bg = "NONE" })
    set_hl("CursorLine", { bg = maybe(cursorln) })
    set_hl("ColorColumn", { bg = maybe(bg1) })
    set_hl("CursorColumn", { bg = maybe(bg1) })

    set_hl("Pmenu", { fg = fg0, bg = maybe(pmenu) })
    set_hl("PmenuSel", { fg = fg0, bg = maybe(pmenu_sel) })
    set_hl("PmenuSbar", { bg = maybe(blend(bg0, pmenu, 0.25)) })
    set_hl("PmenuThumb", { bg = maybe(blend(lack, pmenu, 0.30)) })

    set_hl("Search", { fg = black, bg = yellow, bold = o.bold })
    set_hl("IncSearch", { fg = black, bg = lack, bold = o.bold })
    set_hl("CurSearch", { fg = black, bg = red, bold = o.bold })
    set_hl("MatchParen", { fg = lack, bg = maybe(blend(lack, bg0, 0.16)), bold = o.bold })

    set_hl("Visual", { bg = maybe(sel) })
    set_hl("VisualNOS", { bg = maybe(sel) })

    set_hl("StatusLine", { fg = fg0, bg = maybe(bg3) })
    set_hl("StatusLineNC", { fg = fg2, bg = maybe(bg1) })
    set_hl("TabLine", { fg = fg2, bg = maybe(bg1) })
    set_hl("TabLineSel", { fg = fg0, bg = maybe(bg3), bold = o.bold })
    set_hl("TabLineFill", { fg = fg2, bg = maybe(bg1) })

    set_hl("Folded", { fg = lack, bg = maybe(blend(lack, bg0, 0.10)), italic = true })
    set_hl("FoldColumn", { fg = fg3, bg = "NONE" })

    set_hl("Title", { fg = yellow, bold = o.bold })
    set_hl("Directory", { fg = lack })
    set_hl("SpecialKey", { fg = fg2 })
    set_hl("NonText", { fg = fg3 })
    set_hl("Whitespace", { fg = fg3 })
    set_hl("Conceal", { fg = fg2 })

    set_hl("ErrorMsg", { fg = red, bold = o.bold })
    set_hl("WarningMsg", { fg = yellow, bold = o.bold })
    set_hl("MoreMsg", { fg = lack, bold = o.bold })
    set_hl("Question", { fg = lack, bold = o.bold })
    set_hl("ModeMsg", { fg = fg0, bold = o.bold })

    set_hl("DiffAdd", { fg = "NONE", bg = maybe(blend(green, bg0, 0.16)) })
    set_hl("DiffChange", { fg = "NONE", bg = maybe(blend(lack, bg0, 0.12)) })
    set_hl("DiffDelete", { fg = "NONE", bg = maybe(blend(red, bg0, 0.15)) })
    set_hl("DiffText", { fg = "NONE", bg = maybe(blend(yellow, bg0, 0.30)) })

    set_hl("SpellBad", { sp = red, undercurl = true })
    set_hl("SpellCap", { sp = lack, undercurl = true })
    set_hl("SpellLocal", { sp = green, undercurl = true })
    set_hl("SpellRare", { sp = yellow, undercurl = true })

    -- Syntax (minimal color noise)
    set_hl("Comment", { fg = fg2, italic = o.italic_comments })
    set_hl("Identifier", { fg = fg0 })
    set_hl("Function", { fg = yellow })
    set_hl("Statement", { fg = fg1, italic = o.italic_keywords })
    set_hl("Keyword", { fg = fg1, italic = o.italic_keywords })
    set_hl("Conditional", { fg = fg1, italic = o.italic_keywords })
    set_hl("Repeat", { fg = fg1 })
    set_hl("Operator", { fg = fg1 })
    set_hl("Constant", { fg = yellow })
    set_hl("String", { fg = green })
    set_hl("Character", { fg = green })
    set_hl("Number", { fg = yellow })
    set_hl("Boolean", { fg = yellow })
    set_hl("Float", { fg = yellow })
    set_hl("Type", { fg = yellow })
    set_hl("StorageClass", { fg = yellow })
    set_hl("Structure", { fg = yellow })
    set_hl("Typedef", { fg = yellow })
    set_hl("PreProc", { fg = fg1 })
    set_hl("Special", { fg = yellow })
    set_hl("Todo", { fg = black, bg = maybe(yellow), bold = o.bold })
    link("luaNumber", "Number")
    link("luaString", "String")

    -- Treesitter Standard Captures
    link("@comment", "Comment")
    link("@string", "String")
    link("@string.regex", "String")
    link("@string.escape", "Special")
    link("@character", "Character")
    link("@character.special", "Special")
    link("@number", "Number")
    link("@boolean", "Boolean")
    link("@float", "Float")
    link("@function", "Function")
    link("@function.builtin", "Special")
    link("@function.call", "Function")
    link("@function.macro", "Macro")
    link("@method", "Function")
    link("@method.call", "Function")
    link("@constructor", "Constructor")
    link("@parameter", "Identifier")
    link("@keyword", "Keyword")
    link("@keyword.function", "Keyword")
    link("@keyword.operator", "Operator")
    link("@keyword.return", "Keyword")
    link("@conditional", "Conditional")
    link("@repeat", "Repeat")
    link("@debug", "Debug")
    link("@label", "Label")
    link("@include", "Include")
    link("@exception", "Exception")
    link("@type", "Type")
    link("@type.builtin", "Type")
    link("@type.definition", "Typedef")
    link("@type.qualifier", "Type")
    link("@storageclass", "StorageClass")
    link("@attribute", "PreProc")
    link("@field", "Identifier")
    link("@property", "Identifier")
    link("@variable", "Identifier")
    link("@variable.builtin", "Special")
    link("@constant", "Constant")
    link("@constant.builtin", "Special")
    link("@constant.macro", "Define")
    link("@namespace", "Include")
    link("@symbol", "Identifier")
    link("@text", "Normal")
    link("@text.strong", "Bold")
    link("@text.emphasis", "Italic")
    link("@text.underline", "Underlined")
    link("@text.strike", "Strikethrough")
    link("@text.title", "Title")
    link("@text.literal", "String")
    link("@text.uri", "Underlined")
    link("@tag", "Tag")
    link("@tag.attribute", "Identifier")
    link("@tag.delimiter", "Delimiter")

    -- LaTeX
    set_hl("texCmd", { fg = yellow })
    set_hl("texStatement", { fg = fg1 })
    set_hl("texSection", { fg = yellow, bold = o.bold })
    set_hl("texDelimiter", { fg = fg1 })
    set_hl("texMathZone", { fg = fg0 })
    set_hl("texMath", { fg = fg0 })

    -- LSP/diagnostics
    set_hl("LspReferenceText", { bg = maybe(blend(lack, bg0, 0.10)) })
    link("LspReferenceRead", "LspReferenceText")
    link("LspReferenceWrite", "LspReferenceText")
    set_hl("LspSignatureActiveParameter", { fg = yellow, bold = o.bold })
    set_hl("LspInlayHint", { fg = fg3, bg = maybe(blend(fg3, bg0, 0.12)), italic = true })

    set_hl("DiagnosticError", { fg = red })
    set_hl("DiagnosticWarn", { fg = yellow })
    set_hl("DiagnosticInfo", { fg = lack })
    set_hl("DiagnosticHint", { fg = lack })
    set_hl("DiagnosticOk", { fg = green })
    set_hl("DiagnosticUnderlineError", { undercurl = true, sp = red })
    set_hl("DiagnosticUnderlineWarn", { undercurl = true, sp = yellow })
    set_hl("DiagnosticUnderlineInfo", { undercurl = true, sp = lack })
    set_hl("DiagnosticUnderlineHint", { undercurl = true, sp = lack })
    set_hl("DiagnosticVirtualTextError", { fg = red, bg = maybe(blend("#a0454e", bg0, 0.22)) })
    set_hl("DiagnosticVirtualTextWarn", { fg = yellow, bg = maybe(blend("#a1834c", bg0, 0.20)) })
    set_hl("DiagnosticVirtualTextInfo", { fg = lack, bg = maybe(blend(lack, bg0, 0.18)) })
    set_hl("DiagnosticVirtualTextHint", { fg = lack, bg = maybe(blend(lack, bg0, 0.18)) })

    -- Telescope
    set_hl("TelescopeNormal", { fg = fg0, bg = maybe(floatbg) })
    set_hl("TelescopeBorder", { fg = border, bg = maybe(floatbg) })
    set_hl("TelescopeTitle", { fg = lack, bold = o.bold })
    set_hl("TelescopeSelection", { fg = fg0, bg = maybe(pmenu_sel) })
    set_hl("TelescopeMatching", { fg = yellow, bold = o.bold })

    -- nvim-cmp
    set_hl("CmpItemAbbr", { fg = fg0 })
    set_hl("CmpItemAbbrDeprecated", { fg = fg2, strikethrough = true })
    set_hl("CmpItemAbbrMatch", { fg = lack, bold = o.bold })
    set_hl("CmpItemAbbrMatchFuzzy", { fg = lack, italic = true })
    set_hl("CmpItemMenu", { fg = fg2 })
    set_hl("CmpBorder", { fg = border, bg = maybe(floatbg) })
    set_hl("CmpDocBorder", { fg = border, bg = maybe(floatbg) })
    local kind = {
        Text = fg0,
        Method = yellow,
        Function = yellow,
        Constructor = yellow,
        Field = fg0,
        Variable = fg0,
        Class = yellow,
        Interface = yellow,
        Module = fg1,
        Property = fg0,
        Unit = lack,
        Value = yellow,
        Enum = yellow,
        Keyword = fg1,
        Snippet = yellow,
        Color = lack,
        File = fg0,
        Reference = fg0,
        Folder = lack,
        EnumMember = yellow,
        Constant = yellow,
        Struct = yellow,
        Event = yellow,
        Operator = fg1,
        TypeParameter = yellow,
    }
    for k, c in pairs(kind) do set_hl("CmpItemKind" .. k, { fg = c }) end

    -- Git / explorers / misc
    set_hl("GitSignsAdd", { fg = green })
    set_hl("GitSignsChange", { fg = lack }); set_hl("GitSignsDelete", { fg = red })
    set_hl("NvimTreeNormal", { fg = fg0, bg = maybe(bg0) })
    set_hl("NvimTreeWinSeparator", { fg = border, bg = maybe(bg0) })
    set_hl("NvimTreeRootFolder", { fg = yellow, bold = o.bold })
    set_hl("NvimTreeFolderName", { fg = lack })
    set_hl("NeoTreeNormal", { fg = fg0, bg = maybe(bg0) })
    set_hl("NeoTreeDirectoryName", { fg = lack })
    set_hl("NeoTreeRootName", { fg = yellow, bold = o.bold })

    set_hl("IndentBlanklineChar", { fg = fg3 })
    set_hl("IndentBlanklineContextChar", { fg = blend(lack, bg0, 0.45) })
    set_hl("IblIndent", { fg = fg3 })
    set_hl("IblScope", { fg = blend(lack, bg0, 0.45) })

    set_hl("NotifyBackground", { bg = maybe(floatbg) })
    for _, t in ipairs({ "INFO", "WARN", "ERROR", "DEBUG", "TRACE" }) do
        set_hl("Notify" .. t .. "Border", { fg = border, bg = maybe(floatbg) })
    end
    set_hl("NotifyINFOTitle", { fg = lack, bold = o.bold })
    set_hl("NotifyWARNTitle", { fg = yellow, bold = o.bold })
    set_hl("NotifyERRORTitle", { fg = red, bold = o.bold })
    set_hl("NotifyTRACETitle", { fg = lack, bold = o.bold })

    set_hl("MasonNormal", { fg = fg0, bg = maybe(floatbg) })
    set_hl("MasonHeader",
        { fg = black, bg = yellow, bold = o.bold })
    set_hl("LazyNormal", { fg = fg0, bg = maybe(floatbg) })
    set_hl("LazyH1", { fg = black, bg = lack, bold = o.bold })
    set_hl("NoicePopup", { fg = fg0, bg = maybe(floatbg) })
    set_hl("NoiceCmdlineIcon", { fg = lack })
    set_hl("NoiceCmdlinePopupBorder", { fg = border })

    set_hl("DapBreakpoint", { fg = red })
    set_hl("DapBreakpointCondition", { fg = yellow })
    set_hl("DapStopped", { fg = yellow, bg = maybe(blend(yellow, bg0, 0.10)) })
    set_hl("TroubleNormal", { fg = fg0, bg = maybe(floatbg) })
    set_hl("TroubleText", { fg = fg0 })
    set_hl("TroubleCount", { fg = lack, bg = maybe(blend(lack, bg0, 0.14)) })
    set_hl("DashboardHeader", { fg = lack })
    set_hl("DashboardFooter", { fg = fg2, italic = true })
    set_hl("DashboardCenter", { fg = fg0 })
    set_hl("HopNextKey", { fg = lack, bold = o.bold })
    set_hl("HopNextKey1", { fg = yellow, bold = o.bold })
    set_hl("HopNextKey2", { fg = red })

    if o.transparent then
        for _, g in ipairs({ "NormalFloat", "SignColumn", "StatusLine", "StatusLineNC", "TabLine", "TabLineFill", "TabLineSel", "CursorLine", "WinBar", "WinBarNC", "TelescopeNormal", "TelescopeBorder", "WhichKeyFloat", "TroubleNormal", "MasonNormal", "LazyNormal" }) do
            local hl = vim.api.nvim_get_hl(0, { name = g, link = false })
            if hl and hl.bg then hl.bg = "NONE" end
            set_hl(g, hl)
        end
    end
end

apply()

return M
