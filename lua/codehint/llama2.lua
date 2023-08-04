local ENDPOINT = "127.0.0.1:5000/api/completions"
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

local function generate_completion(code)
    local prompt = string.format(
        "<s>[INST] <<SYS>>\n%s\n<</SYS>>\n\n%s[/INST]",
        SYSTEM,
        code
    )

    local payload = vim.json.encode({
        prompt = prompt,
    })

    local curl = (
        string.format("curl %s", ENDPOINT)
        .. " -H 'Content-Type: application/json'"
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

local Llama2 = {}

function Llama2.generate(code)
    local content = generate_completion(code)

    return content
end

return { Llama2 = Llama2 }
