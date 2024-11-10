local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local COMPLETION = methods.internal.COMPLETION

-- based on pattern from cmp-luasnip
local pattern = "\\%([^[:alnum:][:blank:]]\\+\\|\\w\\+\\)"
local regex = vim.regex([[\%(]] .. pattern .. [[\)\m$]])

local function nvim_snippet_exists()
    local status, _ = pcall(require, "snippets")

    return status
end

local function get_loaded_snippets()
    return require("snippets").get_loaded_snippets()
end

return h.make_builtin({
    name = "nvim_snippets",
    can_run = nvim_snippet_exists,
    condition = nvim_snippet_exists,
    runtime_condition = h.cache.by_bufnr(function()
        return not vim.tbl_isempty(get_loaded_snippets())
    end),
    meta = {
        url = "https://github.com/garymjr/nvim-snippets",
        description = "Snippets managed by nvim-snippets.",
    },
    method = COMPLETION,
    filetypes = {},
    generator = {
        --- @param params NullLsParams
        --- @param done fun()
        fn = function(params, done)
            local line_to_cursor = params.content[params.row]:sub(1, params.col)
            local start_col = regex:match_str(line_to_cursor)

            if nil == start_col then
                done({ { items = {}, isIncomplete = true } })
                return
            end

            local items = {}
            local snips = get_loaded_snippets()
            for _, item in pairs(snips) do
                if vim.startswith(item.prefix, line_to_cursor:sub(start_col + 1)) then
                    items[#items + 1] = {
                        label = item.prefix,
                        kind = vim.lsp.protocol.CompletionItemKind.Snippet,
                        insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
                        detail = item.description,
                        insertText = (type(item.body) == "table") and table.concat(item.body, "\n") or item.body,
                    }
                end
            end
            done({ { items = items, isIncomplete = #items == 0 } })
        end,
        async = true,
    },
})
