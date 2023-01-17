local config = require("codehint.config")
local parsers = require("nvim-treesitter.parsers")

local Comment = {}

function Comment.get_comment()
    local buffer = vim.api.nvim_get_current_buf()
    local parser = parsers.get_parser(buffer)

    local win = vim.api.nvim_get_current_win()
    local line = vim.api.nvim_win_get_cursor(win)[1]

    local language = parser:language_for_range({ line, 0, line, 0 }):lang()
    return config.languages[language].comment
end

return { Comment = Comment }
