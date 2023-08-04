local OpenAI = require("codehint.openai").OpenAI

local function makeDiagnostic(bug)
    return {
        lnum = bug["line"],
        col = 1,
        end_lnum = bug["line"],
        severity = vim.diagnostic.severity.HINT,
        message = bug["hint"],
    }
end

local function generate(prompt, opt)
    if opt.provider == "openai" then
        return OpenAI.generate(prompt, opt.args)
    end
end

local M = {}

M._CodehintConfig = {
    provider = "openai",
    args = {
        use_env = false,
        model = "gpt-3.5-turbo",
    },
}

M.setup = function(config)
    if not config then
        config = {}
    end

    M._CodehintConfig = vim.tbl_deep_extend("force", M._CodehintConfig, config)
end

M.hint = function()
    local buffer = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, true)
    local prompt = table.concat(lines, "\n")

    local output = generate(prompt, M._CodehintConfig)

    if output ~= nil then
        local bugs = output["bugs"]
        local diagnostics = {}
        for _, bug in ipairs(bugs) do
            table.insert(diagnostics, makeDiagnostic(bug))
        end

        local namespace = vim.api.nvim_create_namespace("codehint")
        vim.diagnostic.set(namespace, buffer, diagnostics)
    end
end

return M
