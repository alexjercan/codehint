local config = require("codehint.config")
local parsers = require("nvim-treesitter.parsers")

local Comment = {}

function Comment.get_comment()
    local buffer = vim.api.nvim_get_current_buf()
    local parser = parsers.get_parser(buffer)

    local win = vim.api.nvim_get_current_win()
    local line = vim.api.nvim_win_get_cursor(win)[1]

    local language = parser:language_for_range({ line, 0, line, 0 }):lang()
    local language_config = config.languages[language]

    if language_config then
        return language_config.comment
    end

    -- TODO: Should probably debug log that the language is not supported
    return ""
end

local Hint = {}

Hint.Q = "Q: Propose a hint that can help me fix the bug"
Hint.A = "A:"

function Hint.make_prompt(lines, line, comment)
    lines[line] = string.format("%s %s Fixme", lines[line], comment)

    table.insert(lines, string.format("%s %s", comment, Hint.Q))
    table.insert(lines, string.format("%s %s", comment, Hint.A))

    return table.concat(lines, "\n")
end

function Hint.query(prompt, key, opt)
    local payload = vim.json.encode({
        model = "code-davinci-002",
        prompt = prompt,
        max_tokens = opt.max_tokens,
        temperature = opt.temperature,
        top_p = opt.top_p,
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

        return vim.json.decode(result)
    end
end

function Hint.format(json, comment)
    return string.format(
        "%s %s\n%s %s%s",
        comment,
        Hint.Q,
        comment,
        Hint.A,
        json["choices"][1]["text"]
    )
end

function Hint.run(lines, line, comment, key, opt)
    local prompt = Hint.make_prompt(lines, line, comment)
    local result = Hint.query(prompt, key, opt)
    if result ~= nil then
        return Hint.format(result, comment)
    end
end

return { Comment = Comment, Hint = Hint }
