local json = require('cjson')
local cURL = require("cURL")

local data_path = vim.fn.stdpath("data")
local api_key_path = string.format("%s/.codexrc", data_path)

local function repr(str)
    return string.format("%q", str):gsub("\\\n", "\\n")
end

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

M.setup = function ()
    local key = get_key()

    if not key then
        print("Could not setup codehint")
    end
end

M.hint = function()
    local key = get_key()

    local comment = "//"
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local line = vim.api.nvim_win_get_cursor(0)[1]

    lines[line] = table.concat({lines[line], comment, "Fixme"}, " ")

    local qstr = string.format("%s Q: Propose a hint that can help me fix the bug", comment)
    local astr = string.format("%s A:", comment)
    table.insert(lines, qstr)
    table.insert(lines, astr)
    local prompt = table.concat(lines, "\n")

    local headers = {
        "Content-Type: application/json",
        string.format("Authorization: Bearer %s", key),
    }

    local body = string.format(
       '{"model": "code-davinci-002", "prompt": %s, "max_tokens": 256, "temperature": 0.5, "top_p": 1}',
       repr(prompt)
    )

    local url = "https://api.openai.com/v1/completions"

    cURL.easy({
        url=url,
        post=true,
        httpheader=headers,
        postfields=body,
        writefunction=function(str)
            local tab = json.decode(str)
            print(string.format("%s\n%s%s", qstr, astr, tab["choices"][1]["text"]))
        end
    }):perform():close()
end

return M
