local Api = {}

function Api.generate_completion(prompt, key, opt)
    local payload = vim.json.encode({
        model = opt.model,
        messages = {
            { role = "system", content = opt.system_prompt },
            { role = "user", content = prompt },
        },
    })

    local curl = (
        string.format("curl %s", opt.endpoint)
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

return { Api = Api }
