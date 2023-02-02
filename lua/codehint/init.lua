local Util = require("codehint.util")
local Comment = Util.Comment
local Hint = Util.Hint

local data_path = vim.fn.stdpath("data")
local api_key_path = string.format("%s/.codexrc", data_path)

local function get_key()
    local file = io.open(api_key_path, "r")

    if file ~= nil then
        local content = file:read("*a")
        file:close()
        return content
    end

    local content = vim.fn.input("OpenAI Key > ", "")
    file = io.open(api_key_path, "w")

    if not file then
        return nil
    end

    file:write(content)
    file:close()

    return content
end

local M = {}

M._CodehintConfig = {
    max_tokens = 256,
    temperature = 0.5,
    top_p = 1,
    use_print = false,
}

M.setup = function(config)
    if not config then
        config = {}
    end
    M._CodehintConfig = vim.tbl_deep_extend("force", M._CodehintConfig, config)

    local key = get_key()

    if not key then
        print("Could not setup codehint")
    end
end

M.hint = function()
    local key = get_key()

    local comment = Comment.get_comment()
    local buffer = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)

    local win = vim.api.nvim_get_current_win()
    local line = vim.api.nvim_win_get_cursor(win)[1]

    local output = Hint.run(lines, line, comment, key, M._CodehintConfig)

    if output ~= nil then
        Hint.show(output, M._CodehintConfig)
    end
end

return M
