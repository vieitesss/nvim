local ls = require("luasnip")
local s = ls.s
local i = ls.i
local t = ls.t

local f = ls.function_node

local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

local snippets, autosnippets = {}, {}

local group = vim.api.nvim_create_augroup("Lua Snippets", { clear = true })
local file_pattern = "*.js"

local reactComponent = s("rcom",
    fmt([[
export const {} = () => {{
    return (
        <div>
            Hola desde {}
        </div>
    );
}}
    ]], {
        i(1, "Componente"),
        rep(1)
    })
)
table.insert(snippets, reactComponent)

local reactUseState = s("usest",
    fmt([[
const [{}, set{}] = useState({});
    ]], {
        i(1, "variable"),
        f(function(arg)
            return arg[1][1]:sub(1, 1):upper() .. arg[1][1]:sub(2)
        end, 1),
        i(2, "initialValue"),
    })
)
table.insert(snippets, reactUseState)

local reactUseEffect = s("useef",
    fmt([[
useEffect(() => {{
    {}
}}, [{}])
    ]], {
            i(2, "// TODO: something here"),
            i(1, "")
        })
)
table.insert(snippets, reactUseEffect)

return snippets, autosnippets
