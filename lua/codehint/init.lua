local Util = require("codehint.util")
local Comment = Util.Comment

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

    lines[line] = table.concat({ lines[line], comment, "Fixme" }, " ")

    local qstr = string.format(
        "%s Q: Propose a hint that can help me fix the bug",
        comment
    )
    local astr = string.format("%s A:", comment)
    table.insert(lines, qstr)
    table.insert(lines, astr)
    local prompt = table.concat(lines, "\n")

    local payload = vim.json.encode({
        model = "code-davinci-002",
        prompt = prompt,
        max_tokens = M._CodehintConfig.max_tokens,
        temperature = M._CodehintConfig.temperature,
        top_p = M._CodehintConfig.top_p,
    })

    local curl = (
        "curl https://api.openai.com/v1/completions"
        .. " -H 'Content-Type: application/json'"
        .. string.format(" -H 'Authorization: Bearer %s'", key)
        .. string.format(" -d '%s'", payload)
        .. " --insecure --silent"
    )
    local handle = io.popen(curl)
    if handle ~= nil then
        local result = handle:read("*a")
        handle:close()

        local hint = vim.json.decode(result)["choices"][1]["text"]
        local output = string.format("%s\n%s%s", qstr, astr, hint)

        print(output)
    end
end

return M
