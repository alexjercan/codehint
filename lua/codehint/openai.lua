local ENDPOINT = "https://api.openai.com/v1/chat/completions"
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
    "analysis": "The program starts by reading the input from standard input \
into the variable n. Then, we iterate from 1 to n using the range function. \
Then we check if the index is divisible by 2 using the modulo operation. If \
the number is divisible by 2 we print it. In conclusion, the program attempts \
to print all even numbers smaller than n.",
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

Do NOT use any explanation text except the JSON output.
]]

local data_path = vim.fn.stdpath("data")
local api_key_path = string.format("%s/.openairc", data_path)

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

local function from_env()
    local key = os.getenv("OPENAI_API_KEY")
    if key ~= nil then
        return key
    end

    return get_key()
end

local function auth(use_env)
    if use_env then
        return from_env()
    end

    return get_key()
end

local function generate_completion(prompt, key, model)
    local payload = vim.json.encode({
        model = model,
        messages = {
            { role = "system", content = SYSTEM },
            { role = "user", content = prompt },
        },
    })

    local curl = (
        string.format("curl %s", ENDPOINT)
        .. " -H 'Content-Type: application/json'"
        .. string.format(" -H 'Authorization: Bearer %s'", key)
        .. string.format(" -d '%s'", payload)
        .. " --silent"
    )

    local handle = io.popen(curl)
    if handle ~= nil then
        local result = handle:read("*a")
        handle:close()

        return vim.json.decode(result)
    end
end

local OpenAI = {}

function OpenAI.generate(prompt, opt)
    local key = auth(opt.use_env)

    local result = generate_completion(prompt, key, opt.model)

    local choices = result["choices"]
    if choices == nil then
        return nil
    end

    local choice = choices[1]
    if choice == nil then
        return nil
    end

    local message = choice["message"]
    if message == nil then
        return nil
    end

    local content = message["content"]
    if content == nil then
        return nil
    end

    return vim.json.decode(content)
end

return { OpenAI = OpenAI }
