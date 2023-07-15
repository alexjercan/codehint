local Auth = require("codehint.auth").Auth
local Hint = require("codehint.hint").Hint

local M = {}

M._CodehintConfig = {
    api = {
        model = "gpt-3.5-turbo",
        endpoint = "https://api.openai.com/v1/chat/completions",
        system_prompt = "Propose a hint that can help me fix the bug",
    },
    use_env = false,
}

M.setup = function(config)
    if not config then
        config = {}
    end

    M._CodehintConfig = vim.tbl_deep_extend("force", M._CodehintConfig, config)

    local key = Auth.auth(M._CodehintConfig.use_env)

    if not key then
        print("Could not setup codehint")
    end
end

M.hint = function()
    local key = Auth.auth(M._CodehintConfig.use_env)

    local buffer = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, true)
    local prompt = table.concat(lines, "\n")

    local output = Hint.generate(prompt, key, M._CodehintConfig.api)

    if output ~= nil then
        local namespace = vim.api.nvim_create_namespace("codehint")
        vim.diagnostic.set(
            namespace,
            buffer,
            {
                {
                    lnum = 1,
                    col = 1,
                    end_lnum = 1,
                    severity = vim.diagnostic.severity.HINT,
                    message = output,
                },
            }
        )
    end
end

return M
