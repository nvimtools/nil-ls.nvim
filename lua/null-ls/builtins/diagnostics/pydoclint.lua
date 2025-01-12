local h = require("null-ls.helpers")
local methods = require("null-ls.methods")
local u = require("null-ls.utils")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS

local overrides = {
    severities = {
        DOC101 = h.diagnostics.severities["warning"],
        DOC102 = h.diagnostics.severities["warning"],
        DOC103 = h.diagnostics.severities["warning"],
        DOC104 = h.diagnostics.severities["warning"],
        DOC105 = h.diagnostics.severities["warning"],
        DOC106 = h.diagnostics.severities["warning"],
        DOC107 = h.diagnostics.severities["warning"],
        DOC108 = h.diagnostics.severities["warning"],
        DOC109 = h.diagnostics.severities["warning"],
        DOC110 = h.diagnostics.severities["warning"],
        DOC111 = h.diagnostics.severities["warning"],
        DOC201 = h.diagnostics.severities["warning"],
        DOC202 = h.diagnostics.severities["warning"],
        DOC203 = h.diagnostics.severities["warning"],
        DOC301 = h.diagnostics.severities["warning"],
        DOC302 = h.diagnostics.severities["warning"],
        DOC303 = h.diagnostics.severities["warning"],
        DOC304 = h.diagnostics.severities["warning"],
        DOC305 = h.diagnostics.severities["warning"],
        DOC306 = h.diagnostics.severities["warning"],
        DOC307 = h.diagnostics.severities["warning"],
        DOC402 = h.diagnostics.severities["warning"],
        DOC403 = h.diagnostics.severities["warning"],
        DOC404 = h.diagnostics.severities["warning"],
        DOC501 = h.diagnostics.severities["warning"],
        DOC502 = h.diagnostics.severities["warning"],
        DOC503 = h.diagnostics.severities["warning"],
        DOC601 = h.diagnostics.severities["warning"],
        DOC602 = h.diagnostics.severities["warning"],
        DOC603 = h.diagnostics.severities["warning"],
        DOC604 = h.diagnostics.severities["warning"],
        DOC605 = h.diagnostics.severities["warning"],
    },
}

return h.make_builtin({
    name = "pydoclint",
    meta = {
        url = "https://github.com/jsh9/pydoclint",
        description = "Pydoclint is a Python docstring linter to check whether a docstring's sections (arguments, returns, raises, ...) match the function signature or function implementation.",
    },
    method = DIAGNOSTICS,
    filetypes = { "python" },
    generator_opts = {
        command = "pydoclint",
        args = function(params)
            return {
                "--show-filenames-in-every-violation-message=true",
                "-q",
                params.temp_path,
            }
        end,
        to_temp_file = true,
        from_stderr = true,
        format = "line",
        check_exit_code = function(code)
            return code <= 2
        end,
        multiple_files = false,
        on_output = function(line)
            -- Filter lines using Lua pattern matching
            if line:match("^[^:]+:%d+:") then
                -- Process the line as needed
                -- Example: Extract components and create a diagnostic
                local filename, row, code, message = line:match("([^:]+):(%d+): (%w+): (.+)")
                if filename and row and code and message then
                    -- Create and return the diagnostic
                    return {
                        filename = filename,
                        row = tonumber(row),
                        code = code,
                        message = message,
                        severity = overrides.severities[code] or h.diagnostics.severities["warning"],
                    }
                end
            end
        end,
    },
    factory = h.generator_factory,
    can_run = function()
        return u.is_executable("null_pydoclint")
    end,
})
