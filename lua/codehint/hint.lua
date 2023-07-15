local Api = require("codehint.api").Api

local Hint = {}

function Hint.generate(prompt, key, opt)
    local result = Api.generate_completion(prompt, key, opt)

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

    return content
end

return { Hint = Hint }
