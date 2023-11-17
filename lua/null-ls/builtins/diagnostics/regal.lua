local h = require("null-ls.helpers")
local methods = require("null-ls.methods")
local log = require("null-ls.logger")

local handle_regal_output = function(params)
    local diags = {}
    if params.output.violations ~= nil then
        for _, d in ipairs(params.output.violations) do
            if d.location ~= nil then
                table.insert(diags, {
                    row = d.location.row,
                    col = d.location.col,
                    source = "regal",
                    message = d.description,
                    severity = vim.diagnostic.severity.ERROR,
                    filename = d.location.file,
                    code = d.title,
                })
            end
        end
    elseif params.err ~= nil then
        log:error(params.output)
    end

    return diags
end

return h.make_builtin({
    name = "regal",
    meta = {
        url = "https://docs.styra.com/regal",
        description = "Regal is a linter for Rego, with the goal of making your Rego magnificent!.",
    },
    method = methods.internal.DIAGNOSTICS_ON_SAVE,
    filetypes = { "rego" },
    generator_opts = {
        command = "regal",
        args = {
            "lint",
            "-f",
            "json",
            "$ROOT",
        },
        format = "json_raw",
        check_exit_code = function(code)
            return code <= 1
        end,
        to_stdin = false,
        from_stderr = true,
        multiple_files = true,
        on_output = handle_regal_output,
    },
    factory = h.generator_factory,
})
