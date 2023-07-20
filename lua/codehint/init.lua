local Auth = require("codehint.auth").Auth
local Hint = require("codehint.hint").Hint

local SYSTEM = [[You are an expert software  developer. Your job is to find the
bugs in the given source code. First you have to provide a step by step
analysis of the source code. Based on the analysis provide a list of the most
probable bugs in a human readable format. Your output must be in JSON format.
You will have to output a list with the name "analysis" which contains the step
by step analysis of the source code. Then you will have to output the list of
bugs, with the name "bugs", which contains objects with the keys "line" for the
line number, "bug" which contains the description of the bug, and "hint" which
is a more human readable hint that can be used to guide the user to fix the
bug, without explicitly stating the bug to obviously.

For example, given the following source code
```
if __name__ == "__main__":
    n = input()
    for i in range(1, n):
        if i % 2 == 0:
            print(i)
```

Your output should be:
```
{
    "analysis": [
        "The program starts by reading the input from standard input into the variable n.",
        "Then, we iterate from 1 to n using the range function.",
        "Then we check if the index is divisible by 2 using the modulo operation.",
        "If the number is divisible by 2 we print it.",
        "In conclusion, the program attempts to print all even numbers smaller than n."
    ],
    "bugs": [
        {
            "line": 1,
            "bug": "input returns a string, but we use n later into the range function \
which requires an int. You can use the int function to fix that and use \
`n = int(input())`",
            "hint": "check the way you handle the input"
        }
    ]
}
```
]]

local function makeDiagnostic(bug)
    return {
        lnum = bug["line"],
        col = 1,
        end_lnum = bug["line"],
        severity = vim.diagnostic.severity.HINT,
        message = bug["hint"],
    }
end

local M = {}

M._CodehintConfig = {
    api = {
        model = "gpt-3.5-turbo",
        endpoint = "https://api.openai.com/v1/chat/completions",
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

    local api = M._CodehintConfig.api
    api["system_prompt"] = SYSTEM

    local output = Hint.generate(prompt, key, api)

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
