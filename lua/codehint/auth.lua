local Auth = {}

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

    return Auth.get_key()
end

Auth.auth = function(use_env)
    if use_env then
        return from_env()
    end

    return get_key()
end

return { Auth = Auth }
